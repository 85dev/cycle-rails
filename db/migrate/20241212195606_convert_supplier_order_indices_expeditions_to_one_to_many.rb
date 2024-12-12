class ConvertSupplierOrderIndicesExpeditionsToOneToMany < ActiveRecord::Migration[7.1]
  def change
        add_reference :supplier_order_indices, :expedition, null: false, foreign_key: true

        drop_table :expeditions_supplier_order_indices
  end
end
