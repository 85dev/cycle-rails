class CreateClientPositionsConsignmentStocks < ActiveRecord::Migration[7.1]
  def change
    create_join_table :client_positions, :consignment_stocks do |t|
      t.index [:client_position_id, :consignment_stock_id]
      t.index [:consignment_stock_id, :client_position_id]
    end
  end
end
