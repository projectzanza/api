class AddLocationToUser < ActiveRecord::Migration[5.0]
  def up
    add_column :users, :country, :string, limit: 2
    add_column :users, :city, :string
    add_column :users, :onsite, :boolean
  end

  def down
    remove_column :users, :country
    remove_column :users, :city
    remove_column :users, :onsite
  end
end
