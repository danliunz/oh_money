class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.string :name, limit: 64, null: false
      t.string :description, limit: 1024
      t.timestamps

      t.index :name, unique: true
    end
  end
end
