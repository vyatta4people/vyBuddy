class VyattaHost < ActiveRecord::Base
  require 'net/ssh'

  belongs_to :user

  belongs_to :ssh_key_pair

  has_one :vyatta_host_state, :foreign_key => :id, :dependent => :destroy

  has_many :displays, :dependent => :destroy

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

  def execute_remote_commands(remote_commands)
    remote_command_results = Array.new
    Net::SSH.start(self.remote_address, self.ssh_key_pair.login_username, :key_data => self.ssh_key_pair.private_key, :timeout => SSH_TIMEOUT) do |ssh|
      remote_commands.each do |remote_command|
        remote_command_result         = Hash.new
        remote_command_result[:data]  = String.new
        result_data_elements          = Array.new
        ssh.exec!(remote_command.full_command) do |channel, stream, data|
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

  def set_daemon_log_parameters
    Log.application   = HOST_DAEMON_NAME
    Log.event_source  = "#{self.hostname}(#{self.id.to_s})"
  end

  def daemon_stdout
    "/dev/null"
  end

  def daemon_stderr
    "/tmp/#{HOST_DAEMON_NAME}.err.#{self.id.to_s}"
  end

  def self.daemon_pids(vyatta_host_id = nil)
    if vyatta_host_id
      vyatta_host_match = vyatta_host_id.to_s
    else
      vyatta_host_match = "[0-9]+"
    end
    daemon_pids = Array.new
    `ps aux | egrep \"^${USER}\" | egrep \"#{HOST_DAEMON_PATH} #{vyatta_host_match}$\"`.split(/\n/).each do |ps_line|
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

end
