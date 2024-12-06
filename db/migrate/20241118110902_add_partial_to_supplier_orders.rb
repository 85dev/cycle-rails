class AddPartialToSupplierOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :supplier_orders, :partial, :boolean
  end
end
