class TaskRemoteCommand < ActiveRecord::Base
  belongs_to :task
  belongs_to :remote_command
  belongs_to :filter

  has_many :displays, :dependent => :destroy

  def html_id
    "task_remote_command_#{self.id.to_s}"
  end

  def html_display_id
    "task_remote_command_display_#{self.id.to_s}"
  end

end
