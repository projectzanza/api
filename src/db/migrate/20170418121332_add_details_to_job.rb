class AddDetailsToJob < ActiveRecord::Migration[5.0]
  def up
    add_column :jobs, :proposed_start_at, :datetime
    add_column :jobs, :proposed_end_at, :datetime
    add_column :jobs, :allow_contact, :boolean, default: true
  end

  def down
    remove_column :jobs, :proposed_start_at
    remove_column :jobs, :proposed_end_at
    remove_column :jobs, :allow_contact
  end
end
