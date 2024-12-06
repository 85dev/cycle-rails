class AddOriginalQuantityToSupplierOrderPositions < ActiveRecord::Migration[7.1]
  def change
    add_column :supplier_order_positions, :original_quantity, :integer, null: false, default: 0
  end
end
