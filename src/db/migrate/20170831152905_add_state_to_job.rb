class AddStateToJob < ActiveRecord::Migration[5.0]
  def change
    add_column :jobs, :completed_at, :datetime
  end
end
