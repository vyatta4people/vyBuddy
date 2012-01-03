class TaskGroup < ActiveRecord::Base
  has_many :tasks, :dependent => :destroy

  def html_id
    "task_group_#{self.id.to_s}"
  end

end
