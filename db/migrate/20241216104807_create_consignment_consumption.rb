class CreateConsignmentConsumption < ActiveRecord::Migration[7.1]
  def change
    create_table :consignment_consumptions do |t|
      t.references :consignment_stock, null: false, foreign_key: true
      t.datetime :begin_date, null: false    
      t.datetime :end_date, null: false
      t.string :number, null: false                           

      t.timestamps
    end
  end
end
