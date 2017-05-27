class AddVerifiedAtToJob < ActiveRecord::Migration[5.0]
  def up
    add_column :jobs, :verified_at, :datetime
  end

  def down
    remove_column :jobs, :verified_at
  end
end
