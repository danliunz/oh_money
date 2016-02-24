class CreateRememberMe < ActiveRecord::Migration
  def change
    create_table :remember_me, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.references :user, index: true, foreign_key: true, null: false
      t.string :digest_token, limit: 256, null: false
      t.timestamps
    end
  end
end
