class User < ActiveRecord::Base
  has_many :ssh_key_pairs
  has_many :vyatta_hosts
end
