class Tag < ActiveRecord::Base
  has_and_belongs_to_many :expense_entries, join_table: "expense_entry_tags"
end
