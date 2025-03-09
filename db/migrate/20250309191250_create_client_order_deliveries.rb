class CreateClientOrderDeliveries < ActiveRecord::Migration[7.1]
  def change
    create_table :client_order_deliveries do |t|
      t.references :part, null: false, foreign_key: true
      t.references :client_order_position, null: false, foreign_key: true
      t.date :delivery_date, null: false
      t.integer :quantity, null: false, default: 0

      t.timestamps
    end
  end
end
