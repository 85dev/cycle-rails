class AddFieldsToSupplierOrderAnsItsPositions < ActiveRecord::Migration[7.1]
  def change
    add_column :supplier_orders, :fully_delivered, :boolean, default: false, null: false
    add_column :supplier_order_positions, :delivered, :boolean, default: false, null: false
  end
end
