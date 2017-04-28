class CreateInterestedUsersJobs < ActiveRecord::Migration[5.0]
  def up
    create_table :interested_users_jobs do |t|
      t.belongs_to :user, type: :uuid
      t.belongs_to :job, type: :uuid
    end

    add_index :interested_users_jobs, [:user_id, :job_id], unique: true
  end

  def down
    drop_table :interested_users_jobs
  end
end
