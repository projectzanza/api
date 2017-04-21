class CreateInvitedUsersJobs < ActiveRecord::Migration[5.0]
  def up
    create_table :invited_users_jobs do |t|
      t.belongs_to :user, type: :uuid
      t.belongs_to :job, type: :uuid
    end
  end

  def down
    drop_table :invited_users_jobs
  end
end
