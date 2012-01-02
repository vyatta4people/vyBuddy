class RemoteCommand < ActiveRecord::Base
  belongs_to :user

  has_many :task_remote_commands
  has_many :tasks, :through => :task_remote_commands

  def executor
    return case self.mode
      when "operational"    then "/opt/vyatta/bin/vyatta-op-cmd-wrapper"
      when "configuration"  then "/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper"
      when "system"         then ""
      else nil
    end
  end

  def full_command
    self.executor + " " + self.command
  end

end
