class CreateClientOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :client_orders do |t|
      t.references :client, null: false, foreign_key: true
      t.references :part, null: false, foreign_key: true
      t.string :transporter
      t.integer :quantity
      t.boolean :order_status
      t.datetime :order_date
      t.datetime :order_delivery_time
      t.datetime :estimated_arrival_time
      t.datetime :estimated_departure_time
      t.datetime :reel_delivery_time
      t.datetime :reel_arrival_time
      t.integer :number
      t.string :batch

      t.timestamps
    end
  end
end
