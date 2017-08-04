class CreatePaymentTokens < ActiveRecord::Migration[5.0]
  def change
    create_table :payment_tokens, id: :uuid do |t|
      t.references :user, type: :uuid
      t.references :job, type: :uuid
      t.jsonb :token
    end
  end
end
