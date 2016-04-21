class CreateExpenseEntries < ActiveRecord::Migration
  def change
    create_table :expense_entries do |t|
      t.integer :item_type_id, null: false
      t.integer :user_id, null: false
      t.integer :cost, null: false
      t.datetime :purchase_date
      t.string :description, limit: 1024
      t.timestamps

      t.index :item_type_id
    end
  end
end
