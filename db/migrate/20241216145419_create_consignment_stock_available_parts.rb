class CreateConsignmentStockAvailableParts < ActiveRecord::Migration[7.1]
  def change
    create_table :consignment_stock_parts do |t|
      t.references :consignment_stock, null: false, foreign_key: true
      t.references :part, null: false, foreign_key: true
      t.integer :current_quantity, null: false, default: 0

      t.timestamps
    end
  end
end
