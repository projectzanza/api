class AddRocketchatToken < ActiveRecord::Migration[5.0]
  def up
    add_column :users, :rc_token, :string
    add_column :users, :rc_uid, :string
    add_column :users, :rc_password, :string
  end

  def down
    remove_column :users, :rc_token
    remove_column :users, :rc_uid
    remove_column :users, :rc_password
  end
end
