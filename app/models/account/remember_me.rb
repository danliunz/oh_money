class Account::RememberMe < ActiveRecord::Base
  belongs_to :user
  
  validates :digest_token, presence: true
end
