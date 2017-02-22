class CreateReplies < ActiveRecord::Migration[5.0]
  def change
    create_table :replies, id: :uuid do |t|
      t.string :text
      t.string :job_id
      t.string :user_id
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
