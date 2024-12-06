class CreateJoinTableClientOrdersOrderPositions < ActiveRecord::Migration[7.1]
  def change
    create_join_table :client_orders, :order_positions do |t|
      t.index [:client_order_id, :order_position_id]
      t.index [:order_position_id, :client_order_id]
    end
  end
end
