class User < ActiveRecord::Base
  has_secure_password
  
  has_one :remember_me, class_name: "Account::RememberMe"
  
  validates :name, presence: true
  validates :password, length: 6..20
end
