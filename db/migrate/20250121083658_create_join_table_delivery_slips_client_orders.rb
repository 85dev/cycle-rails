class CreateJoinTableDeliverySlipsClientOrders < ActiveRecord::Migration[7.1]
  def change
    create_join_table :client_orders, :delivery_slips do |t|
      t.index [:client_order_id, :delivery_slip_id]
      t.index [:delivery_slip_id, :client_order_id]
    end
  end
end
