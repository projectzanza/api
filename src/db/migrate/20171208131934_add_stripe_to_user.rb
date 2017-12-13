class AddStripeToUser < ActiveRecord::Migration[5.0]
  def up
    add_column :users, :stripe_state_token, :string
    add_column :users, :stripe_state_token_updated_at, :datetime
    add_column :users, :stripe_access_token, :string
    add_column :users, :stripe_scope, :string
    add_column :users, :stripe_refresh_token, :string
    add_column :users, :stripe_user_id, :string
    add_column :users, :stripe_publishable_key, :string
  end

  def down
    remove_column :users, :stripe_state_token
    remove_column :users, :stripe_access_token
    remove_column :users, :stripe_scope
    remove_column :users, :stripe_refresh_token
    remove_column :users, :stripe_user_id
    remove_column :users, :stripe_publishable_key
  end
end
