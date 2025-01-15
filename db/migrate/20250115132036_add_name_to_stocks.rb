class AddNameToStocks < ActiveRecord::Migration[7.1]
  def change
    add_column :standard_stocks, :name, :string, null: true
    add_column :consignment_stocks, :name, :string, null: true
  end
end
