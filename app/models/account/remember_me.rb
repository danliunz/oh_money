class Account::RememberMe < ActiveRecord::Base
  belongs_to :user, dependent: :destroy
  
  validates :digest_token, presence: true
end
