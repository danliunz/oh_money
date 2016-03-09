class ExpenseEntry < ActiveRecord::Base
  belongs_to :item_type
  belongs_to :user, class_name: "Account::User"
  has_and_belongs_to_many :tags, join_table: "expense_entry_tags"
end
