class Task < ActiveRecord::Base
  belongs_to :task_group

  has_many :task_remote_commands, :dependent => :destroy
  has_many :remote_commands, :through => :task_remote_commands

  validates :name, :match_hostname, :presence => true

  validates :name, :uniqueness => { :scope => :task_group_id }

  default_scope select("`tasks`.*").joins(:task_group).order(["`task_groups`.`sort_order` ASC", "`task_groups`.`name` ASC", "`tasks`.`sort_order` ASC", "`tasks`.`name` ASC"])

  scope :enabled,   where(:is_enabled => true)
  scope :disabled,  where(:is_enabled => false)

  scope :background,    where(:is_on_demand => false)
  scope :on_demand,     where(:is_on_demand => true)

  before_create :set_sort_order
  before_create :set_defaults

  def title
    return "#{self.name} (OD)" if self.is_on_demand
    return "#{self.name} (BG)"
  end

  def applicable?(vyatta_host)
    return true if vyatta_host.hostname.match(/#{self.match_hostname}/i)
    return false
  end

  def html_name
    "<div style=\"color:##{self.task_group.color}\">#{self.name}</div>"
  end

  def html_id
    "task_#{self.id.to_s}"
  end

  def html_container_id
    "task_#{self.id.to_s}_container"
  end

  def html_button_container_id
    "task_#{self.id.to_s}_button_container"
  end

  def html_execute_button_id
    "task_#{self.id.to_s}_execute_button"
  end

  def html_comment_button_id
    "task_#{self.id.to_s}_comment_button"
  end

  def html_comment_container_id
    "task_#{self.id.to_s}_comment_container"
  end

private

  def set_sort_order
    self.sort_order = Task.get_next_sort_order(:task_group_id, self.task_group_id)
  end

  def set_defaults
    self.is_on_demand = false if !self.is_on_demand
    self.is_enabled   = false if !self.is_enabled
    return true
  end

end
