class AddStateToJob < ActiveRecord::Migration[5.0]
  def change
    add_column :jobs, :completed_at, :datetime
    change_column :jobs, :state, :string, null: false
  end
end
