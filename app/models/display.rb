class Display < ActiveRecord::Base

  belongs_to :vyatta_host
  belongs_to :task_remote_command

  has_one :task, :through => :task_remote_command

  default_scope select("`displays`.*").joins(:task_remote_command).joins(:task).order(["`tasks`.`sort_order` ASC"])

  def html_display_id
    self.task_remote_command.html_display_id
  end

end
