class CreateClientPositions < ActiveRecord::Migration[7.1]
  def change
    create_table :client_positions do |t|
      t.references :client, null: false, foreign_key: true
      t.references :part, null: false, foreign_key: true
      t.integer :quantity
      t.string :location
      t.boolean :consignment_stock

      t.timestamps
    end
  end
end
