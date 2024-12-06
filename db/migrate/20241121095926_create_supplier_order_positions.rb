class CreateSupplierOrderPositions < ActiveRecord::Migration[7.1]
  def change
    create_table :supplier_order_positions do |t|
      t.references :supplier_order, null: false, foreign_key: true  # Links to supplier_orders table
      t.references :part, null: false, foreign_key: true           # Links to parts table
      t.float :price, null: false                                  # Price per unit of the part
      t.integer :quantity, null: false                             # Quantity of the part ordered
      t.datetime :delivery_date, null: false  
      
      t.timestamps
    end
  end
end
