class CreateJoinTableSupplierOrdersOrderPositions < ActiveRecord::Migration[7.1]
  def change
    create_join_table :supplier_orders, :order_positions do |t|
      t.index [:supplier_order_id, :order_position_id]
      t.index [:order_position_id, :supplier_order_id]
    end
  end
end
