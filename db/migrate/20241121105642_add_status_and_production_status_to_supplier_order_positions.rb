class AddStatusAndProductionStatusToSupplierOrderPositions < ActiveRecord::Migration[7.1]
  def change
    add_column :supplier_order_positions, :status, :string
  end
end
