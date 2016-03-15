class Account::User < ActiveRecord::Base
  NAME_LENGTH_RANGE =  3..64
  PASSWORD_LENGTH_RANGE = 6..64

  has_one :remember_me

  # Each user owns item types created by himself
  has_many :item_types, inverse_of: :user, dependent: :destroy

  # Each user owns tags created by himself
  has_many :tags, inverse_of: :user, dependent: :destroy

  has_many :expense_entries, inverse_of: :user, dependent: :destroy

  validates_length_of :name, within: NAME_LENGTH_RANGE

  validates_format_of :name, with: /\A[[[:alnum:]]_]+\z/,
    message: "can only contain digit, alphabetic character or underscore"

  validates_uniqueness_of :name, message: "has been taken by others",
    if: proc { |user| user.errors[:name].empty? }

  validates_length_of :password, within: PASSWORD_LENGTH_RANGE, on: :create

  validates_confirmation_of :password, allow_blank: true,
    message: "should match password", on: :create

  has_secure_password validations: false
end
