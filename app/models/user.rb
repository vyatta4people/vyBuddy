class User < ActiveRecord::Base

  has_many :ssh_key_pairs

  validates :username, :email, :password, :presence => true

  validates :username, :email, :uniqueness => true

  validates :username,
    :format     => { :with => USERNAME_REGEX, :message => USERNAME_REASON }

  validates :email,
    :format     => { :with => EMAIL_REGEX, :message => EMAIL_REASON }

  default_scope order(["`username` ASC"])

  scope :enabled,   where(:is_enabled => true)
  scope :disabled,  where(:is_enabled => false)

  before_create  :set_defaults
  before_destroy { |user| return false if user.id == DEFAULT_USER_ID }
  before_destroy { |user| return false if user.ssh_key_pairs.count > 0 }

private

  def set_defaults
    self.receives_notifications     = false if !self.receives_notifications
    self.is_admin                   = false if !self.is_admin
    self.is_enabled                 = false if !self.is_enabled
    return true
  end

end
