class CreateStandardStocks < ActiveRecord::Migration[7.1]
  def change
    create_table :standard_stocks do |t|
      t.references :client, null: false, foreign_key: true
      t.string :address
      t.string :contact_name
      t.string :contact_email
      
      t.timestamps
    end
  end
end
