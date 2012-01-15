class SshKeyPair < ActiveRecord::Base
  belongs_to :user

  has_many :vyatta_hosts
  
  scope :sorted, order(["`identifier` ASC"])

end
