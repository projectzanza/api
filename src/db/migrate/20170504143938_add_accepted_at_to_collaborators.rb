class AddAcceptedAtToCollaborators < ActiveRecord::Migration[5.0]
  def up
    add_column :collaborators, :accepted_at, :datetime
  end

  def down
    remove_column :collaborators, :accepted_at
  end
end
