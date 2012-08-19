class Task < ActiveRecord::Base

  belongs_to :task_group

  has_many :task_remote_commands, :dependent => :destroy
  has_many :remote_commands,  :through => :task_remote_commands
  has_many :filters,          :through => :task_remote_commands

  has_many :task_vyatta_host_groups, :dependent => :destroy
  has_many :vyatta_host_groups, :through => :task_vyatta_host_groups

  validates :name, :match_hostname, :presence => true

  validates :name, :uniqueness => { :scope => :task_group_id }

  validates :group_applicability,
    :inclusion  => { :in => GROUP_APPLICABILITIES, :message => "\'%{value}\' is not a valid group applicability" }

  default_scope select("`tasks`.*").joins(:task_group).order(["`task_groups`.`sort_order` ASC", "`task_groups`.`name` ASC", "`tasks`.`sort_order` ASC", "`tasks`.`name` ASC"])

  scope :enabled,   where(:is_enabled => true)
  scope :disabled,  where(:is_enabled => false)

  scope :mass, where(:is_singleton => false)

  scope :background,    where(:is_on_demand => false)
  scope :on_demand,     where(:is_on_demand => true)

  before_create :set_sort_order
  before_create :set_defaults

  before_save :set_writer_task_attributes

  def title
    title = self.name
    if self.is_on_demand and !self.is_writer
      title += " (OD)"
    elsif self.is_writer
      title += " (WR)"
    else
      title += " (BG)"
    end
    title += " *" if self.is_singleton
    return title
  end

  def writer?
    self.is_writer
  end

  def group_applicability
    super.to_sym
  end

  def applicable?(vyatta_host)
    if self.group_applicability != :global
      if self.vyatta_host_groups.include?(vyatta_host.vyatta_host_group)
        return false if self.group_applicability == :exclusive
      else
        return false if self.group_applicability == :inclusive
      end
    end
    return false if !vyatta_host.hostname.match(/#{self.match_hostname}/i)
    return true
  end

  def html_name
    "<div style=\"color:##{self.task_group.color}\">#{self.name}</div>"
  end

  def html_id
    "task_#{self.id.to_s}"
  end

  def html_dummy_id
    "task_#{self.id.to_s}_dummy"
  end

  def html_not_applicable_id
    "task_#{self.id.to_s}_not_applicable"
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

  def html_united_information_id
    "task_#{self.id.to_s}_united_information"
  end

private

  def set_sort_order
    self.sort_order = Task.get_next_sort_order(:task_group_id, self.task_group_id)
  end

  def set_defaults
    self.is_on_demand = false if !self.is_on_demand
    self.is_singleton = false if !self.is_singleton
    self.is_writer    = false if !self.is_writer
    self.is_enabled   = false if !self.is_enabled
    self.comment      = ""    if !self.comment
    return true
  end

  def set_writer_task_attributes
    if self.writer?
      self.is_on_demand = true
      self.is_singleton = true
    end
    return true
  end

end
