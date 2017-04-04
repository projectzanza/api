class AddPerDiemToJob < ActiveRecord::Migration[5.0]
  def up
    add_column :jobs, :per_diem, :integer
  end

  def down
    remove_column :jobs, :per_diem
  end
end
