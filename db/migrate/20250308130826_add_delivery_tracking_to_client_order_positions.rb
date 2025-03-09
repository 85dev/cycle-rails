class AddDeliveryTrackingToClientOrderPositions < ActiveRecord::Migration[7.1]
  def change
    add_column :client_order_positions, :real_quantity_delivered, :integer
    add_column :client_order_positions, :partial_quantity_delivered, :integer
  end
end
