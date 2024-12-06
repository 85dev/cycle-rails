class RemoveSupplierOrderIdFromOrderPositions < ActiveRecord::Migration[7.1]
  def change
    remove_column :order_positions, :supplier_order_id, :bigint
  end
end
