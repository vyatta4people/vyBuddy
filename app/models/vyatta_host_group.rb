class VyattaHostGroup < ActiveRecord::Base
  has_many :vyatta_hosts

  has_many :task_vyatta_host_groups, :dependent => :destroy
  has_many :tasks, :through => :task_vyatta_host_groups

  validates :name, :presence => true

  validates :name, :uniqueness => true

  validates :color, :presence => true

  validates :color, :format => { :with => /^[0-9a-f]{6}$/, :message => "must be valid RGB color" }

  default_scope order(["`sort_order` ASC", "`name` ASC"])

  scope :enabled,   where(:is_enabled => true)
  scope :disabled,  where(:is_enabled => false)

  before_create     :set_sort_order
  before_create     :set_defaults
  before_validation :set_color
  before_destroy { |vyatta_host_group| return false if vyatta_host_group.id == DEFAULT_HOST_GROUP_ID }
  before_destroy { |vyatta_host_group| return false if vyatta_host_group.vyatta_hosts.count > 0 }

  def html_name
    "<div style=\"color:##{self.color}\">#{self.name}</div>"
  end

  def number_of_members
    self.vyatta_hosts.count
  end

  def list_of_members
    self.vyatta_hosts.collect{ |vyatta_host| vyatta_host.hostname }
  end

  def html_list_of_members
    "<div style=\"color:##{self.color}\">#{self.list_of_members.join("<br/>")}</div>"
  end

private

  def set_sort_order
    self.sort_order = VyattaHostGroup.get_next_sort_order
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
