class CreateClientOrderPositions < ActiveRecord::Migration[7.1]
  def change
    create_table :client_order_positions do |t|
      t.references :client_order, null: false, foreign_key: true
      t.references :part, null: false, foreign_key: true
      t.integer :quantity
      t.float :price
      t.datetime :delivery_date
      t.string :status

      t.timestamps
    end
  end
end
