class CreatePayments < ActiveRecord::Migration[5.0]
  def change
    create_table :payments, id: :uuid do |t|
      t.jsonb :charge
      t.references :job, type: :uuid
      t.references :estimate, type: :uuid
      t.references :recipient, type: :uuid, references: :user
      t.references :chargee, type: :uuid, references: :user
      t.timestamps
    end
  end
end
