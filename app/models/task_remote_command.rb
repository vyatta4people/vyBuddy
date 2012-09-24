class TaskRemoteCommand < ActiveRecord::Base

  belongs_to :task
  belongs_to :remote_command
  belongs_to :filter

  has_many :displays, :dependent => :destroy

  validate :validate_safety

  default_scope select("`task_remote_commands`.*").joins(:remote_command).order(["`task_remote_commands`.`sort_order` ASC", "`remote_commands`.`command` ASC"])

  before_create :set_sort_order
  
  before_save :set_defaults

  before_save { |trc| trc.command_extension = trc.command_extension.strip }

  def mode
    self.remote_command.mode
  end

  def command
    [self.remote_command.command, self.command_extension].join(" ").strip
  end

  def full_command(variable_parameters = nil)
    if !variable_parameters
      [self.remote_command.full_command, self.command_extension].join(" ").strip
    else
      command_extension = self.command_extension
      variable_parameters.keys.each do |k|
        command_extension = command_extension.gsub(/#{VARIABLE_BEGIN_STRING}#{k}#{VARIABLE_END_STRING}/, variable_parameters[k].strip)
      end
      [self.remote_command.full_command, command_extension].join(" ").strip
    end
  end

  def html_id
    "task_remote_command_#{self.id.to_s}"
  end

  def html_display_id
    "task_remote_command_display_#{self.id.to_s}"
  end

private

  def set_sort_order
    self.sort_order = TaskRemoteCommand.get_next_sort_order(:task_id, self.task_id)
  end

  def set_defaults
    self.command_extension = "" if !self.command_extension
    return true
  end

  def validate_safety
    if !self.task.writer?
      if self.remote_command.configuration? and !self.remote_command.command.match(/^show/)
        self.errors[:task_id] << "\'#{self.task.name}\' must be writer to accept command \'#{self.command}\'"
        return false
      end
    end
    return true
  end

end