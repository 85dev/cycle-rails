class AddPartialQuantityDeliveredToSupplierOrderPositions < ActiveRecord::Migration[7.1]
  def change
    add_column :supplier_order_positions, :partial_quantity_delivered, :integer
    add_column :supplier_order_positions, :real_quantity_delivered, :integer
  end
end
