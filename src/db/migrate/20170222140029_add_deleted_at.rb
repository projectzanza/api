class AddDeletedAt < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :deleted_at, :datetime
    add_column :jobs, :deleted_at, :datetime
  end
end
