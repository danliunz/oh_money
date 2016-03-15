class ExpenseEntry < ActiveRecord::Base
  CENTS_MULTIPLIER = 100.0

  belongs_to :item_type
  belongs_to :user, class_name: "Account::User"
  has_and_belongs_to_many :tags, join_table: "expense_entry_tags"

  validates_numericality_of :cost, only_integer: true, greater_than_or_equal_to: 0,
    message: "is not valid money"
  validates_presence_of :purchase_date,
    message: "is not valid date"

  validates_presence_of :item_type, :user
  validates_associated :item_type, :tags
end
