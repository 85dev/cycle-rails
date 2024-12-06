class AddSupplierOrderIndexToClientPositions < ActiveRecord::Migration[7.1]
  def change
    add_reference :client_positions, :supplier_order_index, null: false, foreign_key: true
  end
end
