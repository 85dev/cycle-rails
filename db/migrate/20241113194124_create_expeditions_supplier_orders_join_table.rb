class CreateExpeditionsSupplierOrdersJoinTable < ActiveRecord::Migration[7.1]
  def change
    create_join_table :supplier_orders, :expeditions do |t|
      t.index [:supplier_order_id, :expedition_id]
      t.index [:expedition_id, :supplier_order_id]
    end
  end
end
