class RenameRealQuantityDeliveredInClientOrderPositions < ActiveRecord::Migration[7.1]
  def change
    add_column :client_order_positions, :remaining_quantity_to_be_delivered, :integer, default: 0
  end
end
