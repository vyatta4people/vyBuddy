class TaskGroup < ActiveRecord::Base
  has_many :tasks

  validates :name, :presence => true

  validates :name, :uniqueness => true

  default_scope order(["`sort_order` ASC", "`name` ASC"])

  scope :enabled,   where(:is_enabled => true)
  scope :disabled,  where(:is_enabled => false)

  before_create :set_sort_order
  before_create :set_defaults
  before_destroy { |task_group| return false if task_group.tasks.count > 0 }

  def html_id
    "task_group_#{self.id.to_s}"
  end

private

  def set_sort_order
    self.sort_order = TaskGroup.get_next_sort_order
  end

  def set_defaults
    self.is_enabled = false if !self.is_enabled
    return true
  end

end
