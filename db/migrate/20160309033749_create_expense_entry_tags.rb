class CreateExpenseEntryTags < ActiveRecord::Migration
  def change
    create_table :expense_entry_tags, id: false, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.integer :expense_entry_id, null: false
      t.integer :tag_id, null: false

      t.index [:expense_entry_id, :tag_id], unique: true
      t.index [:tag_id, :expense_entry_id], unique: true
    end
  end
end
