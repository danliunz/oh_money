class Tag < ActiveRecord::Base
  belongs_to :user, class_name: "Account::User"
  has_and_belongs_to_many :expense_entries, join_table: "expense_entry_tags"

  validates_presence_of :name, :user
end
