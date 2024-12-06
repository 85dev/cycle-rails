class CreateSupplierOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :supplier_orders do |t|
      t.references :supplier, null: false, foreign_key: true
      t.references :part, null: false, foreign_key: true
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
      t.integer :number
      t.string :batch

      t.timestamps
    end
  end
end
