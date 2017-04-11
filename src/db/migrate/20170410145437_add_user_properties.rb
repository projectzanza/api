class AddUserProperties < ActiveRecord::Migration[5.0]
  def up
    add_column :users, :bio, :text
    add_column :users, :per_diem, :jsonb
  end

  def down
    remove_column :users, :bio
    remove_column :users, :per_diem
  end
end
