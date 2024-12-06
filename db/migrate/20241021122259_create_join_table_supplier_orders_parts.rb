class CreateJoinTableSupplierOrdersParts < ActiveRecord::Migration[7.1]
  def change
    create_join_table :supplier_orders, :parts do |t|
      t.index [:supplier_order_id, :part_id]
      t.index [:part_id, :supplier_order_id]
    end
  end
end
