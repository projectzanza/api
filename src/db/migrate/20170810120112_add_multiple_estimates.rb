class AddMultipleEstimates < ActiveRecord::Migration[5.0]
  def change
    remove_column :collaborators, :estimate_id
    add_column :estimates, :user_id, :uuid
    add_column :estimates, :job_id, :uuid
    add_column :estimates, :accepted_at, :datetime
    add_column :estimates, :rejected_at, :datetime
  end
end
