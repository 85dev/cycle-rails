class ChangeOrderStatusToBeStringInClientOrders < ActiveRecord::Migration[7.1]
  def change
    change_column :client_orders, :order_status, :string, default: 'undelivered', null: false
  end
end
