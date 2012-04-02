class VyattaHost < ActiveRecord::Base
  require 'net/ssh'
  require 'net/sftp'

  belongs_to :user

  belongs_to :ssh_key_pair

  has_one :vyatta_host_state, :foreign_key => :id, :dependent => :destroy

  has_many :displays, :dependent => :destroy

  validates :hostname, :remote_address, :presence => true

  validates :hostname, :remote_address, :uniqueness => true

  validates :hostname,
    :length     => { :minimum => 2 }, 
    :format     => { :with => /^[a-zA-Z0-9\-]+$/, :message => "must contain only letters, numbers and hyphens" }

  validates :remote_address,
    :format     => { :with => /^(([1-2]?[0-9]{1,2}\.){3}[1-2]?[0-9]{1,2}|[a-z0-9][a-z0-9\.\-]+[a-z])$/, :message => "must be valid DNS name or IPv4 address" }

  default_scope joins(:vyatta_host_state).select([
    "`vyatta_hosts`.*", 
    "`vyatta_host_states`.`is_daemon_running`", 
    "`vyatta_host_states`.`daemon_pid`", 
    "`vyatta_host_states`.`is_reachable`", 
    "`vyatta_host_states`.`vyatta_version`", 
    "`vyatta_host_states`.`load_average`"])

  scope :sorted, order(["`hostname` ASC"])

  after_create   { |vyatta_host| ActiveRecord::Base.connection.execute("INSERT INTO `vyatta_host_states`(`id`) VALUES(#{vyatta_host.id.to_s});") }
  before_destroy { |vyatta_host| vyatta_host.kill_all_daemons; return true }

  def set_core_log_parameters
    Log.event_source  = "#{self.hostname}(#{self.id.to_s})"
  end

  def set_daemon_log_parameters
    Log.application   = HOST_DAEMON_NAME
    Log.event_source  = "#{self.hostname}(#{self.id.to_s})"
  end

  attr_accessor :execute_via_ssh_message
  def execute_via_ssh(command)
    data = String.new
    Net::SSH.start(self.remote_address, self.ssh_key_pair.login_username, :key_data => self.ssh_key_pair.private_key, :timeout => SSH_TIMEOUT) do |ssh|
      begin
        data = ssh.exec!(command)
      rescue => e
        self.execute_via_ssh_message = e.message
        return nil
      end
    end
    return data
  end

  attr_accessor :upload_via_sftp_message
  def upload_via_sftp(local_path, remote_path)
    Net::SFTP.start(self.remote_address, self.ssh_key_pair.login_username, :key_data => self.ssh_key_pair.private_key, :timeout => SSH_TIMEOUT) do |sftp|
      begin
        sftp.upload!(local_path, remote_path)
      rescue => e
        self.upload_via_sftp_message = e.message
        return nil
      end
    end
    return true
  end

  def execute_remote_commands(remote_commands)
    remote_command_results = Array.new
    Net::SSH.start(self.remote_address, self.ssh_key_pair.login_username, :key_data => self.ssh_key_pair.private_key, :timeout => SSH_TIMEOUT) do |ssh|
      remote_commands.each do |remote_command|
        remote_command_result         = Hash.new
        remote_command_result[:data]  = String.new
        result_data_elements          = Array.new
        full_remote_command = case remote_command.class.to_s
          when "RemoteCommand" then remote_command.full_command
          when "Hash"          then RemoteCommand.full_command(remote_command[:mode], remote_command[:command])
          else RemoteCommand.full_command(DEFAULT_REMOTE_COMMAND_MODE, remote_command.to_s)
        end
        ssh.exec!(full_remote_command) do |channel, stream, data|
          result_data_elements << data
        end
        remote_command_result[:data] = result_data_elements.join
        remote_command_results << remote_command_result
      end
    end
    return remote_command_results
  end

  def execute_remote_command(remote_command)
    self.execute_remote_commands([remote_command])[0]
  end

  def daemon_stdout
    "/dev/null"
  end

  def daemon_stderr
    if ENV["VYBUDDY_LOG_DIR"]
      stderr_dir = ENV["VYBUDDY_LOG_DIR"]
    else
      stderr_dir = "/tmp"
    end
    "#{stderr_dir}/#{HOST_DAEMON_NAME}.err.#{self.id.to_s}"
  end

  def self.daemon_pids(vyatta_host_id = nil)
    if vyatta_host_id
      vyatta_host_id_match = vyatta_host_id.to_s
    else
      vyatta_host_id_match = "[0-9]+"
    end
    daemon_pids = Array.new
    `ps aux | egrep \"^${USER}\" | egrep \"#{HOST_DAEMON_PATH} #{vyatta_host_id_match}$\"`.split(/\n/).each do |ps_line|
      daemon_pids << ps_line.split(/[ \t]+/)[1].to_i
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

  def start_daemon
    self.set_daemon_log_parameters
    begin
      pid = Process.spawn("#{HOST_DAEMON_PATH} #{self.id.to_s}", STDOUT => self.daemon_stdout, STDERR => self.daemon_stderr)
      Process.detach(pid)
    rescue => e
      Log.error("Could not start daemon: #{e.message}")
      return nil
    else
      self.vyatta_host_state.is_daemon_running  = true
      self.vyatta_host_state.daemon_pid         = pid
      return self.vyatta_host_state.save
    end
  end

  def stop_daemon
    self.set_daemon_log_parameters
    begin
      Process.kill("TERM", self.vyatta_host_state.daemon_pid) if self.vyatta_host_state.daemon_pid != 0
    rescue => e
      Log.error("Could not stop daemon (PID #{self.vyatta_host_state.daemon_pid.to_s}): #{e.message}")
      return nil
    else
      Log.info("Daemon stopped")
      self.vyatta_host_state.is_daemon_running  = false
      self.vyatta_host_state.daemon_pid         = 0
      return self.vyatta_host_state.save
    end
  end

  def os_version
    self.vyatta_version.sub(/^VC/, "").sub(/-.*/, "").to_f
  end

  def executor_label
    if self.os_version >= 6.0 and self.os_version < 6.1
      return "60-61"
    elsif self.os_version >= 6.2
      return "62+"
    else
      return "60-61"
    end
  end

  attr_accessor :verify_executors_message
  def verify_executors(upload_missing = false)
    self.set_core_log_parameters
    self.verify_executors_message = Array.new
    executors        = Hash.new
    modes            = REMOTE_COMMAND_MODES
    modes            << "configuration_real" # Add dummy mode for executor verification
    modes.each do |mode|
      executor                     = Hash.new
      executor[:local_executor]    = RemoteCommand.local_executor(mode)
      if mode == "configuration_real"
        executor[:local_executor]  = executor[:local_executor].sub(/real$/, self.executor_label)
      end
      executor[:remote_executor]   = RemoteCommand.remote_executor(mode)
      executor[:local_md5sum]      = Digest::MD5.hexdigest(File.read(executor[:local_executor]))
      # Remote executor md5sum will be examined during SSH session
      executors[RemoteCommand.executor(mode)] = executor
    end
    unmatched_executor_names = Array.new
    executors.each do |executor_name, executor|
      Net::SSH.start(self.remote_address, self.ssh_key_pair.login_username, :key_data => self.ssh_key_pair.private_key, :timeout => SSH_TIMEOUT) do |ssh|
        ssh.open_channel do |channel|
          command = "md5sum #{executor[:remote_executor]}"
          channel.exec(command) do |ch, success|

            raise("Could not execute command using SSH: #{command}") unless success

            channel.on_data do |ch, data|
              executor[:remote_md5sum] = data.sub(/ +.*$/, "").strip
              if executor[:remote_md5sum] != executor[:local_md5sum]
                unmatched_executor_names << executor_name
              end
            end

            channel.on_extended_data do |ch, type, data|
              unmatched_executor_names      << executor_name if !unmatched_executor_names.include?(executor_name)
              self.verify_executors_message << data
            end
          end
        end
        ssh.loop
      end
    end
    if !upload_missing
      if !unmatched_executor_names.empty?
        return false
      else
        return true
      end
    else
      unmatched_executor_names.each do |executor_name|
        executor = executors[executor_name]
        if !self.upload_via_sftp(executor[:local_executor], executor[:remote_executor]) or !self.execute_via_ssh("chmod +x #{executor[:remote_executor]}")
          return nil
        end
      end
      return true
    end
  end

end
