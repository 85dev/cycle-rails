class AddCompletedToClientOrdersAndSupplierOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :client_orders, :completed, :boolean, default: false
  end
end
