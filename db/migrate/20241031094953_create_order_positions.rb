class CreateOrderPositions < ActiveRecord::Migration[7.1]
  def change
    create_table :order_positions do |t|
      t.references :supplier_order, null: false, foreign_key: true
      t.integer :quantity
      t.datetime :real_departure_time
      t.datetime :estimated_departure_time

      t.timestamps
    end
  end
end