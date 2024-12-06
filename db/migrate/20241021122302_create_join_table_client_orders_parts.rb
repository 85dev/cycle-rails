class CreateJoinTableClientOrdersParts < ActiveRecord::Migration[7.1]
  def change
    create_join_table :client_orders, :parts do |t|
      t.index [:client_order_id, :part_id]
      t.index [:part_id, :client_order_id]
    end
  end
end
