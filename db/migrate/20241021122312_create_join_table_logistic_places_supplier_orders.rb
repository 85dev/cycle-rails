class CreateJoinTableLogisticPlacesSupplierOrders < ActiveRecord::Migration[7.1]
  def change
    create_join_table :logistic_places, :supplier_orders do |t|
      t.index [:logistic_place_id, :supplier_order_id]
      t.index [:supplier_order_id, :logistic_place_id]
    end
  end
end
