class CreateReviews < ActiveRecord::Migration[5.0]
  def up
    create_table :reviews, id: :uuid do |t|
      t.references :user, type: :uuid
      t.references :job, type: :uuid
      t.references :subject, type: :uuid, references: :user
      t.integer :ability
      t.integer :communication
      t.integer :speed
      t.integer :overall
      t.text :description
      t.timestamps
    end
  end

  def down
    drop_table :reviews
  end
end
