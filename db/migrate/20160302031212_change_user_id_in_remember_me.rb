class ChangeUserIdInRememberMe < ActiveRecord::Migration
  def change
    change_column_null :remember_me, :user_id, true
  end
end
