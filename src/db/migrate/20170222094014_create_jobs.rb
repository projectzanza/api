class CreateJobs < ActiveRecord::Migration[5.0]
  def change
    create_table :jobs, id: :uuid do |t|
      t.string :title
      t.string :text
      t.string :state
      t.string :user_id, null: false
      t.datetime :closed_at
      t.timestamps
    end
  end
end
