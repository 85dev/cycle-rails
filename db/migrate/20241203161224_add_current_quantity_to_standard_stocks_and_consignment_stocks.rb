class AddCurrentQuantityToStandardStocksAndConsignmentStocks < ActiveRecord::Migration[7.1]
  def change
    add_column :standard_stocks, :current_quantity, :integer
    add_column :consignment_stocks, :current_quantity, :integer
  end
end
