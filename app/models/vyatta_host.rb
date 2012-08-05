class VyattaHost < ActiveRecord::Base

  require 'net/ssh'
  require 'net/sftp'

  belongs_to :vyatta_host_group

  belongs_to :ssh_key_pair

  has_one :vyatta_host_state, :foreign_key => :id, :dependent => :destroy

  has_many :displays, :dependent => :destroy

  validates :ssh_key_pair_id, :hostname, :remote_address, :presence => true

  validates :hostname, :remote_address, :uniqueness => true

  validates :hostname,
    :length     => { :minimum => 2 }, 
    :format     => { :with => /^[a-zA-Z0-9\-]+$/, :message => "must contain only letters, numbers and hyphens" },
    :format     => { :with => /^[a-zA-Z0-9]/,     :message => "must start from letter or number" }

  validates :remote_address,
    :format     => { :with => /^(([1-2]?[0-9]{1,2}\.){3}[1-2]?[0-9]{1,2}|[a-z0-9][a-z0-9\.\-]+[a-z])$/, :message => "must be valid DNS name or IPv4 address" }

  validates :remote_port,
    :numericality => { :only_integer => true, :greater_than_or_equal_to => 1, :less_than_or_equal_to => 65535 }

  validates :polling_interval,
    :numericality => { :only_integer => true, :greater_than_or_equal_to => 30, :less_than_or_equal_to => 86400 }

  default_scope select("`vyatta_hosts`.*").joins(:vyatta_host_group).order([
    "`vyatta_host_groups`.`sort_order` ASC", 
    "`vyatta_host_groups`.`name` ASC", 
    "`vyatta_hosts`.`sort_order` ASC", 
    "`vyatta_hosts`.`hostname` ASC"
  ])

  scope :enabled,   where(:is_enabled => true)
  scope :disabled,  where(:is_enabled => false)

  before_create  :set_sort_order
  before_create  :set_defaults
  after_create   { |vyatta_host| ActiveRecord::Base.connection.execute("INSERT INTO `vyatta_host_states`(`id`,`is_reachable`,`created_at`,`updated_at`) VALUES(#{vyatta_host.id.to_s},1,NOW(),NOW());") }
  before_destroy { |vyatta_host| vyatta_host.kill_all_daemons; return true }

  def label
    "#{self.hostname} (#{self.id.to_s})"
  end

  def html_hostname
    "<div style=\"color:##{self.vyatta_host_group.color}\">#{self.hostname}</div>"
  end

  def reachability
    if self.vyatta_host_state.is_daemon_running
      return 0 if !self.vyatta_host_state.is_reachable
      return 1
    else
      return 2
    end
  end

  def public_reachability
    return case self.reachability
      when 0 then "unreachable"
      when 1 then "reachable"
      else "unknown"
    end
  end

  def is_daemon_running
    self.vyatta_host_state.is_daemon_running
  end
  
  def is_reachable
    self.vyatta_host_state.is_reachable
  end
  
  def vyatta_version
    self.vyatta_host_state.vyatta_version
  end
  
  def load_average
    self.vyatta_host_state.load_average
  end
  
  def set_daemon_log_application
    Log.application = HOST_DAEMON_NAME
  end

  def set_daemon_log_event_source
    Log.event_source = self.label
  end

  def set_daemon_log_parameters
    self.set_daemon_log_application
    self.set_daemon_log_event_source
  end

  def os_version
    self.vyatta_version.sub(/^VC/, "").sub(/-.*/, "").to_f
  end

  #
  # Low-level SSH/SFTP stuff
  #
  attr_accessor :ssh_username
  attr_accessor :ssh_password

  def get_ssh_username
    if self.ssh_username
      ssh_username = self.ssh_username
    else
      ssh_username = self.ssh_key_pair.login_username
    end
    return ssh_username
  end

  def get_ssh_connection_parameters
    ssh_connection_parameters   = Hash.new
    if self.ssh_password
      ssh_connection_parameters[:password]  = self.ssh_password
    else
      ssh_connection_parameters[:key_data]  = self.ssh_key_pair.private_key
    end
    ssh_connection_parameters[:port]        = self.remote_port
    ssh_connection_parameters[:timeout]     = SSH_TIMEOUT
    return ssh_connection_parameters
  end

  attr_accessor :ssh_error
  def execute_commands_via_ssh(commands, execute_as_one = false)

    if execute_as_one
      one_joint_command = commands.join(";")
      commands          = [one_joint_command]
    end

    command_result_sets = Array.new    
    begin
      Net::SSH.start(self.remote_address, self.get_ssh_username, self.get_ssh_connection_parameters) do |ssh|
        commands.each do |command|
          ssh.open_channel do |channel|
            command_result_set = Hash.new
            command_result_set[:success]        = true
            command_result_set[:stdout]         = ""
            command_result_set[:stderr]         = ""
            command_result_set[:data]           = ""
            command_result_set[:exit_status]    = 0

            channel.exec(command) do |ch, success|
              command_result_set[:success] = false unless success

              channel.on_data do |ch, data|
                command_result_set[:stdout] += data
                command_result_set[:data]   += data
              end

              channel.on_extended_data do |ch, type, data|
                command_result_set[:stderr] += data
                command_result_set[:data]   += data
              end

              channel.on_request("exit-status") do |ch, data|
                command_result_set[:exit_status]  = data.read_long
              end

              channel.on_request("exit-signal") do |ch, data|
                command_result_set[:exit_signal]  = data.read_long
              end
            end
            command_result_sets << command_result_set
          end
        end
        ssh.loop
      end
    rescue => e
      self.ssh_error = e.inspect
      return nil
    end
    return command_result_sets
  end

  attr_accessor :ssh_stdout, :ssh_stderr, :ssh_exit_status
  def execute_command_via_ssh!(command)
    command_result_sets = self.execute_commands_via_ssh([command])
    return nil if !command_result_sets or command_result_sets.empty? or !command_result_sets[0] or !command_result_sets[0][:data]
    self.ssh_stdout       = command_result_sets[0][:stdout]
    self.ssh_stderr       = command_result_sets[0][:stderr]
    self.ssh_exit_status  = command_result_sets[0][:exit_status]
    return nil if command_result_sets[0][:exit_status] != 0
    return command_result_sets[0][:data]
  end

  attr_accessor :compare_files_error
  def compare_files_via_ssh!(local_path, remote_path)
    begin
      local_md5sum  = Digest::MD5.hexdigest(File.read(local_path))
      remote_md5sum = self.execute_command_via_ssh!("md5sum #{remote_path}").sub(/ +.*$/, "").strip
    rescue => e
      self.compare_files_error = e.inspect
      return nil
    else
      if local_md5sum == remote_md5sum
        return true
      else
        return false
      end
    end
  end

  attr_accessor :sftp_error
  def upload_file_via_sftp!(local_path, remote_path)
    begin
      Net::SFTP.start(self.remote_address, self.get_ssh_username, self.get_ssh_connection_parameters) do |sftp|
        sftp.upload!(local_path, remote_path)
      end
    rescue => e
      self.sftp_error = e.inspect
      return nil
    end
    return true
  end

  #
  # Inline and stored Vyatta remote commands
  #
  def execute_remote_commands(remote_commands, execute_as_one = false)
    full_remote_commands = Array.new
    remote_commands.each do |remote_command|
      full_remote_command = case remote_command.class.to_s
        when "RemoteCommand" then remote_command.full_command
        when "Hash"          then RemoteCommand.full_command(remote_command[:mode], remote_command[:command])
        else RemoteCommand.full_command(DEFAULT_REMOTE_COMMAND_MODE, remote_command.to_s)
      end
      full_remote_commands << full_remote_command
    end
    return self.execute_commands_via_ssh(full_remote_commands, execute_as_one)
  end

  def execute_remote_command!(remote_command)
    remote_command_result_sets = self.execute_remote_commands([remote_command])
    return nil if !remote_command_result_sets or remote_command_result_sets.empty? or !remote_command_result_sets[0] or !remote_command_result_sets[0][:data]
    return remote_command_result_sets[0][:data]
  end

  def executor_label
    if self.os_version >= 6.0 and self.os_version <= 6.1
      return "60-61"
    elsif self.os_version >= 6.2
      return "62+"
    else
      return nil
    end
  end

  attr_accessor :unmatched_modes
  def verify_executors(modes = [:operational], upload_unmatched = false)
    self.unmatched_modes = Array.new
    modes.each do |mode|
      local_executor  = RemoteCommand.local_executor(mode)
      remote_executor = RemoteCommand.remote_executor(mode)
      if mode == :configuration and self.executor_label
        local_executor = local_executor + '.' + self.executor_label # Configuration mode executor hook
      end
      if !self.compare_files_via_ssh!(local_executor, remote_executor)
        if upload_unmatched 
          if !self.upload_file_via_sftp!(local_executor, remote_executor) or !self.execute_command_via_ssh!("chmod +x #{remote_executor}")
            self.unmatched_modes << mode
          end
        else
          self.unmatched_modes << mode
        end
      end
    end
    if !self.unmatched_modes.empty?
      return false
    end
    return true
  end

  def check_reachability
    !self.execute_command_via_ssh!("/bin/true").nil?
  end

  def get_vyatta_version
    self.execute_remote_command!("show version | grep 'Version' | sed 's/.*: *//'").strip
  end

  def vyatta?
    !self.get_vyatta_version.match(/^V/).nil?
  end

  def get_load_average
    self.execute_remote_command!({:mode => :system, :command => "uptime | sed 's/.*, //'"}).strip.to_f
  end

  def get_hostname
    self.execute_remote_command!({:mode => :system, :command => "hostname"}).strip
  end

  def user_exists?(username)
    !self.execute_remote_command!({:mode => :configuration, :command => "show system login user #{username}"}).match(/encrypted-password/).nil?
  end

  #
  # Tasks
  #
  def execute_task(task)
    task_remote_commands  = task.task_remote_commands(true)
    command_result_sets   = self.execute_remote_commands(task_remote_commands.collect{ |trc| trc.remote_command })
    ci                    = 0
    task_remote_commands.each do |trc|
      remote_command  = trc.remote_command
      filter          = trc.filter
      display         = Display.find(:first, :conditions => { :vyatta_host_id => self.id, :task_remote_command_id => trc.id })
      if !display
        display       = Display.create(:vyatta_host_id => self.id, :task_remote_command_id => trc.id)
      end
      display.information = filter.apply(command_result_sets[ci][:stdout])
      display.save
      ci += 1
    end
    return ci
  end

  def dummify_task(task)
    task_remote_commands  = task.task_remote_commands(true)
    di                    = 0
    task_remote_commands.each do |trc|
      display         = Display.find(:first, :conditions => { :vyatta_host_id => self.id, :task_remote_command_id => trc.id })
      if !display
        display       = Display.create(:vyatta_host_id => self.id, :task_remote_command_id => trc.id)
      end
      display.information = DUMMY_DISPLAY_INFORMATION
      display.save
      di += 1
    end
    return di
  end

  def execute_tasks(task_type = :background)
    task_groups = TaskGroup.enabled
    ti          = 0
    task_groups.each do |task_group|
      tasks = case task_type
        when :all         then task_group.tasks(true).mass.enabled
        when :background  then task_group.tasks(true).mass.enabled.background
        when :on_demand   then task_group.tasks(true).mass.enabled.on_demand
        else nil
      end
      tasks.each do |task|
        if task.applicable?(self)
          self.execute_task(task)
          ti += 1
        else
          self.dummify_task(task)
        end
      end
    end
    return ti
  end

  #
  # Daemon control stuff
  #
  def daemon_stdout
    "/dev/null"
  end

  def daemon_stderr
    if ENV["VYBUDDY_LOG_DIR"]
      stderr_dir = ENV["VYBUDDY_LOG_DIR"]
    else
      stderr_dir = "/tmp"
    end
    "#{stderr_dir}/#{HOST_DAEMON_NAME}.err.#{self.id.to_s}.log"
  end

  def self.daemon_pids(vyatta_host_id = nil)
    if vyatta_host_id
      vyatta_host_id_match = vyatta_host_id.to_s
    else
      vyatta_host_id_match = "[0-9]+"
    end
    daemon_pids = Array.new
    `ps xo pid,command | egrep \"#{HOST_DAEMON_PATH} #{vyatta_host_id_match}$\"`.split(/\n/).each do |ps_line|
      daemon_pids << ps_line.strip.split(/[ \t]+/)[0].to_i
    end
    return daemon_pids
  end

  def daemon_pids
    return VyattaHost.daemon_pids(self.id)
  end

  def daemon_running?
    return !self.daemon_pids.empty?
  end

  def duplicate_daemons_running?
    return self.daemon_pids.length > 1
  end

  def verify_running_daemon?
    return false if self.duplicate_daemons_running?
    return false if !self.daemon_pids.empty? and self.daemon_pids[0] != self.vyatta_host_state.daemon_pid
    return true
  end

  def self.kill_all_daemons(vyatta_host_id = nil)
    daemon_pids = self.daemon_pids(vyatta_host_id)
    daemon_pids.each { |pid| Process.kill("KILL", pid) }
    return daemon_pids.length.zero? ? false : true
  end

  def kill_all_daemons
    VyattaHost.kill_all_daemons(self.id)
  end

  attr_accessor :start_daemon_error
  def start_daemon
    begin
      pid = Process.spawn("#{HOST_DAEMON_PATH} #{self.id.to_s}", STDOUT => self.daemon_stdout, STDERR => self.daemon_stderr)
      Process.detach(pid)
    rescue => e
      self.start_daemon_error = e.inspect
      return nil
    else
      self.vyatta_host_state.is_daemon_running  = true
      self.vyatta_host_state.daemon_pid         = pid
      begin
        self.vyatta_host_state.save!
      rescue => e
        self.start_daemon_error = e.inspect
        return nil
      else
        return true
      end
    end
  end

  attr_accessor :stop_daemon_error
  def stop_daemon
    begin
      Process.kill("TERM", self.vyatta_host_state.daemon_pid) if self.vyatta_host_state.daemon_pid != 0
    rescue => e
      self.stop_daemon_error = e.inspect
      return nil
    else
      self.vyatta_host_state.is_daemon_running  = false
      self.vyatta_host_state.daemon_pid         = 0
      begin
        self.vyatta_host_state.save!
      rescue => e
        self.stop_daemon_error = e.inspect
        return nil
      else
        return true
      end
    end
  end

private

  def set_sort_order
    self.sort_order = VyattaHost.get_next_sort_order(:vyatta_host_group_id, self.vyatta_host_group_id)
  end

  def set_defaults
    self.is_passive   = false if !self.is_passive
    self.is_monitored = false if !self.is_monitored
    self.is_enabled   = false if !self.is_enabled
    return true
  end

end
