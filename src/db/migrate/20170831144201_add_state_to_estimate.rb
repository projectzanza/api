class AddStateToEstimate < ActiveRecord::Migration[5.0]
  def change
    add_column :estimates, :state, :string
  end
end
