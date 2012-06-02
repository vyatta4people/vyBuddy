class Setting < ActiveRecord::Base

  validates :name,
    :length     => { :minimum => 2 },
    :format     => { :with => /^[a-z_]+$/, :message => "must contain only lowercase letters and underscores" },
    :uniqueness => true

  validate :validate_regex

  default_scope order(["`sort_order` ASC", "`name` ASC"])

  def value_type
    super.to_sym
  end

  def public_value
    return case self.value_type
      when :s,:p      then self.value.to_s
      when :i         then self.value.to_i
      when :b         then self.value.to_i != 0
      else nil
    end
  end

  def grid_value
    return self.value.gsub(/./,'*') if self.value_type == :p
    return self.value
  end

  def self.get(name)
    setting = Setting.where(:name => name.to_s).first
    return setting.public_value if setting
    return nil
  end

private

  def validate_regex
    if self.value.match(/#{self.validation_regex}/)
      return true
    else
      self.errors[:value] << self.validation_message
      return false
    end
  end

end
