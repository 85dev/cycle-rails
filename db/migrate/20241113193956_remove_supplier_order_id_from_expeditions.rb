class RemoveSupplierOrderIdFromExpeditions < ActiveRecord::Migration[7.1]
  def change
    remove_column :expeditions, :supplier_order_id, :bigint
  end
end
