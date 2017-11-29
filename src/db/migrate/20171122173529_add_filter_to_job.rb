class AddFilterToJob < ActiveRecord::Migration[5.0]
  def up
    add_column :jobs, :consultant_filter, :jsonb
  end

  def down
    remove_column :jobs, :consultant_filter
  end
end
