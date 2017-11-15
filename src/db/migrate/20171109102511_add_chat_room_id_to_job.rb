class AddChatRoomIdToJob < ActiveRecord::Migration[5.0]
  def up
    add_column :jobs, :chat_room_id, :string
    add_column :users, :chat_id, :string
  end

  def down
    remove_column :jobs, :chat_room_id
    remove_column :users, :chat_id
  end
end
