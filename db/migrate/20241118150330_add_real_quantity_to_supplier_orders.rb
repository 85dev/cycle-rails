class AddRealQuantityToSupplierOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :supplier_orders, :real_quantity, :integer
  end
end
