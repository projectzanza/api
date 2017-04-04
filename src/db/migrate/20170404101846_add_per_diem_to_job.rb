class AddPerDiemToJob < ActiveRecord::Migration[5.0]
  def up
    enable_extension 'citext'

    add_column :jobs, :per_diem, :jsonb
  end

  def down
    remove_column :jobs, :per_diem
  end
end
