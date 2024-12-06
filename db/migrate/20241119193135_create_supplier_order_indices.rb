class CreateSupplierOrderIndices < ActiveRecord::Migration[7.1]
  def change
    create_table :supplier_order_indices do |t|
      t.references :supplier_order, null: false, foreign_key: true
      t.integer :quantity
      t.boolean :previsionnal
      t.string :transporter
      t.string :departure_address
      t.string :arrival_address
      t.datetime :order_date
      t.datetime :order_delivery_time
      t.datetime :estimated_arrival_time
      t.datetime :estimated_departure_time
      t.datetime :reel_delivery_time
      t.datetime :reel_arrival_time
      t.boolean :delivery_status
      t.string :batch
      t.string :quantity_status
      t.string :status
      t.string :number
      t.boolean :partial
      t.float :price
      t.integer :shipped_quantity

      t.timestamps
    end
  end
end
