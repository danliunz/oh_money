class CreateItemTypeRelations < ActiveRecord::Migration
  def change
    create_table :item_type_relations do |t|
      t.integer :child_id, null: false
      t.integer :parent_id, null: false

      t.index :child_id
      t.index :parent_id
    end
  end
end
