class AddStateToScope < ActiveRecord::Migration[5.0]
  def change
    add_column :scopes, :state, :string, null: false
  end
end
