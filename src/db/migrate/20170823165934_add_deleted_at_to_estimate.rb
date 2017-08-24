class AddDeletedAtToEstimate < ActiveRecord::Migration[5.0]
  def change
    add_column :estimates, :deleted_at, :datetime
    add_index :estimates, :deleted_at
  end
end
