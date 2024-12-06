class AddQuantityStatusToSupplierOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :supplier_orders, :quantity_status, :string
  end
end
