class TaskGroup < ActiveRecord::Base
  has_many :tasks, :dependent => :destroy

  validates :name, :presence => true

  validates :name, :uniqueness => true

  default_scope order(["`sort_order` ASC", "`name` ASC"])

  scope :enabled,   where(:is_enabled => true)
  scope :disabled,  where(:is_enabled => false)

  before_create :set_sort_order

  def html_id
    "task_group_#{self.id.to_s}"
  end

private

  def set_sort_order
    self.sort_order = TaskGroup.get_next_sort_order
  end

end
