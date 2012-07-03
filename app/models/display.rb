class Display < ActiveRecord::Base

  belongs_to :vyatta_host
  belongs_to :task_remote_command

  def html_display_id
    self.task_remote_command.html_display_id
  end

end
