class CreateJoinTableSupplierOrderPositionsClientOrders < ActiveRecord::Migration[7.1]
  def change
    create_join_table :supplier_order_positions, :client_orders do |t|
      t.index [:supplier_order_position_id, :client_order_id]
      t.index [:client_order_id, :supplier_order_position_id]
    end
  end
end
