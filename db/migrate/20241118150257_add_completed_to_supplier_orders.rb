class AddCompletedToSupplierOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :supplier_orders, :completed, :boolean
  end
end
