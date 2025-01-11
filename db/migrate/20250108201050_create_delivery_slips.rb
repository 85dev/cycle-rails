class CreateDeliverySlips < ActiveRecord::Migration[7.1]
  def change
    create_table :delivery_slips do |t|
      t.references :client_order, null: false, foreign_key: true
      t.references :part, null: false, foreign_key: true
      t.references :company, null: false, foreign_key: true
      t.references :expedition_position, null: false, foreign_key: true
      t.references :contact, null: false, foreign_key: true
      
      t.date :transfer_date, null: false
      t.boolean :is_partial, default: false
      t.string :number, null: false
      t.text :packaging_informations
      t.text :transport_conditions
      t.decimal :brut_weight, precision: 10, scale: 2
      t.decimal :net_weight, precision: 10, scale: 2

      t.timestamps
    end
  end
end
