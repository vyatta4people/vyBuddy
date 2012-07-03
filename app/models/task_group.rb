class TaskGroup < ActiveRecord::Base

  has_many :tasks

  validates :name, :presence => true

  validates :name, :uniqueness => true

  validates :color, :presence => true

  validates :color, :format => { :with => /^[0-9a-f]{6}$/, :message => "must be valid RGB color" }

  default_scope order(["`sort_order` ASC", "`name` ASC"])

  scope :enabled,   where(:is_enabled => true)
  scope :disabled,  where(:is_enabled => false)

  before_create       :set_sort_order
  before_create       :set_defaults
  before_validation   :set_color
  before_destroy { |task_group| return false if task_group.tasks.count > 0 }

  def html_name
    "<div style=\"color:##{self.color}\">#{self.name}</div>"    
  end

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

  def set_color
    self.color = self.color.downcase
    return true
  end

end
