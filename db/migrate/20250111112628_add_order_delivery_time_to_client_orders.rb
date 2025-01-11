class AddOrderDeliveryTimeToClientOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :client_orders, :order_delivery_time, :date
  end
end
