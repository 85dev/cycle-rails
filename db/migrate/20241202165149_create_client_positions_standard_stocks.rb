class CreateClientPositionsStandardStocks < ActiveRecord::Migration[7.1]
  def change
    create_join_table :client_positions, :standard_stocks do |t|
      t.index [:client_position_id, :standard_stock_id]
      t.index [:standard_stock_id, :client_position_id]
    end
  end
end
