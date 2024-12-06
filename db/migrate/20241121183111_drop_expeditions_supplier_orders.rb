class DropExpeditionsSupplierOrders < ActiveRecord::Migration[7.1]
  def change
    drop_table :expeditions_supplier_orders
  end
end
