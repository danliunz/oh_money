class User < ActiveRecord::Base
  has_secure_password
  
  validates :name, presence: :true
  validates :password, length: 6..20
end

