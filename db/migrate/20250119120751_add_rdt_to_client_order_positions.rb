class AddRdtToClientOrderPositions < ActiveRecord::Migration[7.1]
  def change
    add_column :client_order_positions, :real_delivery_time, :datetime
  end
end
