class Task < ActiveRecord::Base
  belongs_to :task_group

  has_many :task_remote_commands, :dependent => :destroy
  has_many :remote_commands, :through => :task_remote_commands

  scope :sorted, order(["`sort_order` ASC", "`name` ASC"])

  def html_id
    "task_#{self.id.to_s}"
  end

end
