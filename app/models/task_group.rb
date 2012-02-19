class TaskGroup < ActiveRecord::Base
  has_many :tasks, :dependent => :destroy

  validates :name, :presence => true

  scope :sorted, order(["`sort_order` ASC", "`name` ASC"])

  def html_id
    "task_group_#{self.id.to_s}"
  end

end
