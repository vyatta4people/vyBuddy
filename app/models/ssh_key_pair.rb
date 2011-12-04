class SshKeyPair < ActiveRecord::Base
  belongs_to :user

  has_many :vyatta_hosts
end
