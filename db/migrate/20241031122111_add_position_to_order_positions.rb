class AddPositionToOrderPositions < ActiveRecord::Migration[7.1]
  def change
    add_column :order_positions, :position, :integer
  end
end
