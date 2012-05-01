class Task < ActiveRecord::Base
  belongs_to :task_group

  has_many :task_remote_commands, :dependent => :destroy
  has_many :remote_commands, :through => :task_remote_commands

  validates :name, :presence => true

  validates :name, :uniqueness => true

  default_scope select("`tasks`.*").joins(:task_group).order(["`task_groups`.`sort_order` ASC", "`task_groups`.`name` ASC", "`tasks`.`sort_order` ASC", "`tasks`.`name` ASC"])

  scope :enabled,   where(:is_enabled => true)
  scope :disabled,  where(:is_enabled => false)

  before_create :set_sort_order

  def html_id
    "task_#{self.id.to_s}"
  end

private

  def set_sort_order
    self.sort_order = Task.get_next_sort_order(:task_group_id, self.task_group_id)
  end

end
