class SshKeyPair < ActiveRecord::Base
  belongs_to :user

  has_many :vyatta_hosts

  validates :identifier, :key_type, :login_username, :private_key, :presence => true

  validates :identifier, :uniqueness => true

  validates :identifier,
    :format     => { :with => EMAIL_REGEX, :message => EMAIL_REASON }

  validates :key_type,
    :inclusion  => { :in => SSH_KEY_TYPES, :message => "\'%{value}\' is not a valid SSH key type" }

  validates :login_username,
    :format     => { :with => USERNAME_REGEX, :message => USERNAME_REASON }

  validate :set_public_key_from_private_key

  default_scope order(["`identifier` ASC"])

  before_save :set_attributes
  before_destroy { |ssh_key_pair| return false if ssh_key_pair.vyatta_hosts.count > 0 }

  def get_public_key_from_private_key
    private_key_file = Tempfile.new("vybuddy_private_key.")
    private_key_file.write(self.private_key)
    private_key_file.rewind
    public_key = `ssh-keygen -y -P" " -f #{private_key_file.path} 2>/dev/null`.strip.sub(/^[a-z\-]+ /, "")
    private_key_file.close
    private_key_file.unlink
    return public_key if $?.to_i == 0 and !public_key.empty?
    return nil
  end

  def set_public_key_from_private_key
    public_key = self.get_public_key_from_private_key
    if public_key
      self.public_key = public_key
      return true
    end
    self.errors[:private_key] << "is invalid or unsupported"
    return false
  end

  def set_attributes
    self.private_key = self.private_key.strip
  end

end
