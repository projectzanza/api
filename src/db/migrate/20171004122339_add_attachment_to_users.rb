class AddAttachmentToUsers < ActiveRecord::Migration[5.0]
  def up
    add_attachment :users, :avatar
    add_column :users, :avatar_upload_url, :string
  end

  def down
    remove_attachment :users, :avatar
    remove_column :users, :avatar_upload_url
  end
end
