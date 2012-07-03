class TaskRemoteCommand < ActiveRecord::Base

  belongs_to :task
  belongs_to :remote_command
  belongs_to :filter

  has_many :displays, :dependent => :destroy

  default_scope select("`task_remote_commands`.*").joins(:remote_command).order(["`task_remote_commands`.`sort_order` ASC", "`remote_commands`.`command` ASC"])

  before_create :set_sort_order

  def mode
    self.remote_command.mode
  end

  def command
    self.remote_command.command
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

end
