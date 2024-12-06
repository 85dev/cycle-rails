class CreateParts < ActiveRecord::Migration[7.1]
  def change
    create_table :parts do |t|
      t.string :designation
      t.string :reference
      t.string :material
      t.string :drawing
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
