class SshKeyPair < ActiveRecord::Base
  belongs_to :user

  has_many :vyatta_hosts

  validates :identifier, :key_type, :login_username, :public_key, :private_key, :presence => true

  validates :identifier,
    :format     => { :with => EMAIL_REGEX, :message => EMAIL_REASON }

  validates :key_type,
    :inclusion  => { :in => SSH_KEY_TYPES, :message => "\'%{value}\' is not a valid SSH key type" }

  validates :login_username,
    :format     => { :with => USERNAME_REGEX, :message => USERNAME_REASON }

  scope :sorted, order(["`identifier` ASC"])

end
