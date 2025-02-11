class CreateOrderSlips < ActiveRecord::Migration[7.1]
  def change
    create_table :order_slips do |t|
      t.references :supplier_order_position, foreign_key: true
      t.references :supplier_order, foreign_key: true
      t.references :contact, foreign_key: true
      t.references :transporter, foreign_key: true
      t.string :informations

      t.timestamps
    end
  end
end
