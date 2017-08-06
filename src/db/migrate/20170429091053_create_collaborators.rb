class CreateCollaborators < ActiveRecord::Migration[5.0]
  def up
    create_table :collaborators, id: :uuid do |t|
      t.references :user, type: :uuid
      t.references :job, type: :uuid
      t.datetime :invited_at
      t.datetime :interested_at
      t.datetime :awarded_at
    end

    add_index :collaborators, %i[user_id job_id], unique: true
  end

  def down
    drop_table :collaborators
  end
end
