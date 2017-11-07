class AddAdminToUser < ActiveRecord::Migration[5.0]
  def up
    add_column :users, :admin, :bool
    add_column :users, :certified, :bool
  end

  def down
    remove_column :users, :admin
    remove_column :users, :certified
  end
end
