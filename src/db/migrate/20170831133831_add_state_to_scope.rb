class AddStateToScope < ActiveRecord::Migration[5.0]
  def change
    add_column :scopes, :state, :string
  end
end
