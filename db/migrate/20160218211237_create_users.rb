class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name, limit: 128, null: false
      t.string :password_digest, limit: 128, null: false
      t.timestamps

      t.index :name, unique: true
    end
  end
end
