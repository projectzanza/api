class AddStateToCollaborator < ActiveRecord::Migration[5.0]
  def up
    add_column :collaborators, :state, :string, null: false
    add_column :collaborators, :rejected_at, :datetime
  end

  def down
    remove_column :collaborators, :state
  end
end
