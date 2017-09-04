class AddStateToEstimate < ActiveRecord::Migration[5.0]
  def change
    add_column :estimates, :state, :string, null: false
  end
end
