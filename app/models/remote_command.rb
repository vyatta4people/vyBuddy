class RemoteCommand < ActiveRecord::Base

  belongs_to :user

  has_many :task_remote_commands
  has_many :tasks,    :through => :task_remote_commands
  has_many :filters,  :through => :task_remote_commands

  validates :mode, :command, :presence => true

  validates :command, :uniqueness => {:scope => :mode}

  validates :mode,
    :inclusion  => { :in => REMOTE_COMMAND_MODES, :message => "\'%{value}\' is not a valid remote command mode" }

  default_scope order(["`mode` DESC, `command` ASC"])

  before_destroy { |remote_command| return false if remote_command.task_remote_commands.count > 0 }

  def name
    self.command
  end

  def mode
    super.to_sym
  end

  def system?
    return true if self.mode == :system
    return false
  end

  def operational?
    return true if self.mode == :operational
    return false
  end

  def configuration?
    return true if self.mode == :configuration
    return false
  end

  def executor
    RemoteCommand.executor(self.mode)
  end

  def local_executor
    RemoteCommand.local_executor(self.mode)
  end

  def remote_executor
    RemoteCommand.remote_executor(self.mode)
  end

  def full_command
    RemoteCommand.full_command(self.mode, self.command)
  end

  class << self

    def executor(mode)
      return case mode
        when :operational         then "vybuddy-op-cmd-wrapper"
        when :configuration       then "vybuddy-cfg-cmd-wrapper"
        when :system              then "vybuddy-sys-cmd-wrapper"
        else nil
      end
    end

    def local_executor(mode)
      executor = self.executor(mode)
      if executor
        return "./#{EXECUTORS_LOCAL_DIR}/#{executor}"
      end
      return nil
    end

    def remote_executor(mode)
      executor = self.executor(mode)
      if executor
        return "#{EXECUTORS_REMOTE_DIR}/#{executor}"
      end
      return nil
    end

    def full_command(mode, command)
      self.remote_executor(mode) + " " + command
    end

  end

end
