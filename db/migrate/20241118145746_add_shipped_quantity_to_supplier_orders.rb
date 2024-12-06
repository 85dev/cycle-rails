class AddShippedQuantityToSupplierOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :supplier_orders, :shipped_quantity, :integer
  end
end
