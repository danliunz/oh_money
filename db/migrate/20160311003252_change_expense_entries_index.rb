class ChangeExpenseEntriesIndex < ActiveRecord::Migration
  def change
    remove_index :expense_entries, column: :item_type_id
    add_index :expense_entries, [:user_id, :item_type_id]
  end
end
