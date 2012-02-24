class Task < ActiveRecord::Base
  belongs_to :task_group

  has_many :task_remote_commands, :dependent => :destroy
  has_many :remote_commands, :through => :task_remote_commands

  validates :name, :presence => true

  validates :name, :uniqueness => true

  scope :sorted, joins(:task_group).order(["`task_groups`.`sort_order` ASC", "`task_groups`.`name` ASC", "`tasks`.`sort_order` ASC", "`tasks`.`name` ASC"])

  def html_id
    "task_#{self.id.to_s}"
  end

end
