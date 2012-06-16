class VyattaHostGroup < ActiveRecord::Base

  has_many :vyatta_hosts

  validates :name, :presence => true

  validates :name, :uniqueness => true

  default_scope order(["`sort_order` ASC", "`name` ASC"])

  scope :enabled,   where(:is_enabled => true)
  scope :disabled,  where(:is_enabled => false)

  before_create :set_sort_order
  before_create :set_defaults

private

  def set_sort_order
    self.sort_order = VyattaHostGroup.get_next_sort_order
  end

  def set_defaults
    self.is_enabled = false if !self.is_enabled
    return true
  end

end
