class AddQuantityStatusToSupplierOrderPositions < ActiveRecord::Migration[7.1]
  def change
    add_column :supplier_order_positions, :quantity_status, :string
  end
end
