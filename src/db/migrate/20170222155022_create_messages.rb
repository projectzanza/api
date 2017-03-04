class CreateMessages < ActiveRecord::Migration[5.0]
  def change
    create_table :messages, id: :uuid do |t|
      t.string :text
      t.string :job_id, null: false
      t.string :user_id, null: false
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
