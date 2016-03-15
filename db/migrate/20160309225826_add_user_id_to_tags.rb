class AddUserIdToTags < ActiveRecord::Migration
  def change
    add_column :tags, :user_id, :integer, null: false

    remove_index :tags, column: :name, unique: true
    add_index :tags, [:user_id, :name], unique: true
  end
end
