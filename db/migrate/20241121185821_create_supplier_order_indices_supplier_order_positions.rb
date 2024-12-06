class CreateSupplierOrderIndicesSupplierOrderPositions < ActiveRecord::Migration[7.1]
  def change
    create_join_table :supplier_order_indices, :supplier_order_positions do |t|
      t.index [:supplier_order_index_id, :supplier_order_position_id]
      t.index [:supplier_order_position_id, :supplier_order_index_id]
    end
  end
end
