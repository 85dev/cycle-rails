class RemovePartIdFromClientOrders < ActiveRecord::Migration[7.1]
  def change
    remove_column :client_orders, :part_id, :bigint
  end
end
