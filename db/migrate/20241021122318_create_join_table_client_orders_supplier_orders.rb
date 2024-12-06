class CreateJoinTableClientOrdersSupplierOrders < ActiveRecord::Migration[7.1]
  def change
    create_join_table :client_orders, :supplier_orders do |t|
      t.index [:client_order_id, :supplier_order_id]
      t.index [:supplier_order_id, :client_order_id]
    end
  end
end
