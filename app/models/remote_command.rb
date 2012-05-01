class RemoteCommand < ActiveRecord::Base
  belongs_to :user

  has_many :task_remote_commands, :dependent => :destroy
  has_many :tasks, :through => :task_remote_commands

  validates :mode, :command, :presence => true

  validates :command, :uniqueness => {:scope => :mode}

  validates :mode,
    :inclusion  => { :in => REMOTE_COMMAND_MODES, :message => "\'%{value}\' is not a valid remote command mode" }

  validate :validate_safety

  default_scope order(["`mode` DESC, `command` ASC"])

  def validate_safety
    if self.mode == :configuration and !self.command.match(/^show/)
      self.errors[:command] << "\'#{self.command}\' is unsafe for #{self.mode} mode"
      return false
    end
    return true
  end

  def mode
    super.to_sym
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
        return "#{ENV['VYBUDDY_RAILS_APP_DIR']}/#{EXECUTORS_LOCAL_DIR}/#{executor}"
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
