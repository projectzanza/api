class AddEstimateToCollaborators < ActiveRecord::Migration[5.0]
  def up
    add_column :collaborators, :days, :integer
    add_column :collaborators, :start_date, :datetime
    add_column :collaborators, :end_date, :datetime
    add_monetize :collaborators, :per_diem
    add_monetize :collaborators, :total
  end

  def down
    remove_column :collaborators, :days
    remove_column :collaborators, :start_date
    remove_column :collaborators, :end_date
    remove_monetize :collaborators, :per_diem
    remove_monetize :collaborators, :total
  end
end
