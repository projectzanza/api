class CreateScopes < ActiveRecord::Migration[5.0]
  def change
    create_table :scopes, id: :uuid do |t|
      t.references :job, type: :uuid
      t.string :title
      t.text :description
      t.datetime :completed_at
      t.datetime :verified_at
      t.timestamps
    end
  end
end
