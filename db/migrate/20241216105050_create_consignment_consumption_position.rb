class CreateConsignmentConsumptionPosition < ActiveRecord::Migration[7.1]
  def change
    create_table :consignment_consumption_positions do |t|
      t.references :consignment_consumption, null: false, foreign_key: true
      t.references :part, null: false, foreign_key: true
      t.integer :quantity, null: false
      t.decimal :price, precision: 10, scale: 2

      t.timestamps
    end
  end
end
