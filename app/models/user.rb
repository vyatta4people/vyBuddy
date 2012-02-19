class User < ActiveRecord::Base
  has_many :ssh_key_pairs
  has_many :vyatta_hosts

  validates :username, :email, :password, :presence => true

  validates :username,
    :format     => { :with => USERNAME_REGEX, :message => USERNAME_REASON }

  validates :email,
    :format     => { :with => EMAIL_REGEX, :message => EMAIL_REASON }

  scope :sorted, order(["`username` ASC"])
end
