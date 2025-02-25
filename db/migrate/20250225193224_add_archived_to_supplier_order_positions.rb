class AddArchivedToSupplierOrderPositions < ActiveRecord::Migration[7.1]
  def change
    add_column :supplier_order_positions, :archived, :boolean, default: false
  end
end
