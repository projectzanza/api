class AddProfileInfo < ActiveRecord::Migration[5.0]
  def up
    add_column :users, :headline, :string
    rename_column :users, :bio, :summary

    create_table :positions, id: :uuid do |t|
      t.uuid :user_id
      t.string :title
      t.text :summary
      t.string :company
      t.datetime :start_at
      t.datetime :end_at
      t.datetime :deleted_at
      t.timestamps
    end

    add_column :scopes, :deleted_at, :datetime
  end

  def down
    remove_column :users, :headline
    rename_column :users, :summary, :bio
    drop_table :positions
    remove_column :scopes, :deleted_at
  end
end
