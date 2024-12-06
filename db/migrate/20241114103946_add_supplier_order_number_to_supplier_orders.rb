class AddSupplierOrderNumberToSupplierOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :supplier_orders, :supplier_order_number, :string
  end
end
