class RemovePartIdFromSupplierOrders < ActiveRecord::Migration[7.1]
  def change
    remove_column :supplier_orders, :part_id, :bigint
  end
end
