class CreateExpeditionsSupplierOrderIndices < ActiveRecord::Migration[7.1]
  def change
    create_join_table :expeditions, :supplier_order_indices do |t|
      t.index [:supplier_order_index_id, :expedition_id]
      t.index [:expedition_id, :supplier_order_index_id]
    end
  end
end
