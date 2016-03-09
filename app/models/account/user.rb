class Account::User < ActiveRecord::Base
  NAME_LENGTH_RANGE =  3..64
  PASSWORD_LENGTH_RANGE = 6..64

  has_one :remember_me

  # Each user has his own ItemTypes
  has_many :item_types, dependent: :destroy

  validates_length_of :name, within: NAME_LENGTH_RANGE

  validates_format_of :name, with: /\A[[[:alnum:]]_]+\z/,
    message: "can only contain digit, alphabetic character or underscore"

  validates_uniqueness_of :name, message: "has been taken by others",
    if: proc { |user| user.errors[:name].empty? }

  validates_length_of :password, within: PASSWORD_LENGTH_RANGE

  validates_confirmation_of :password, allow_blank: true,
    message: "should match password"

  has_secure_password validations: false
end
