class AddPaymentAccount < ActiveRecord::Migration[5.0]
  def change
    create_table :payment_accounts, id: :uuid do |t|
      t.references :user, type: :uuid
      t.jsonb :customer
    end

    add_column :jobs, :payment_card_id, :string
  end
end
