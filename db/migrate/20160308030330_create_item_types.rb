class CreateItemTypes < ActiveRecord::Migration
  def change
    create_table :item_types do |t|
      t.string :name, limit: 64, null: false
      t.integer :user_id, null: false
      t.string :description, limit: 1024
      t.timestamps

      t.index [:user_id, :name], unique: true
    end
  end
end
