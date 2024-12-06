class RemoveSupplierOrderIdFromLogisticPlaces < ActiveRecord::Migration[7.1]
  def change
    remove_column :logistic_places, :supplier_order_id, :bigint
  end
end
