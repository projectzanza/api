class CreateEstimates < ActiveRecord::Migration[5.0]
  def up
    create_table :estimates, id: :uuid do |t|
      t.integer :days
      t.datetime :start_at
      t.datetime :end_at
      t.monetize :per_diem
      t.monetize :total
      t.timestamps
    end

    add_column :collaborators, :estimate_id, :uuid
  end

  def down
    drop_table :estimates
    remove_column :collaborators, :estimate
  end
end
