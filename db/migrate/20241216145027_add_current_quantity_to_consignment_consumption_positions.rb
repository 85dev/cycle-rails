class AddCurrentQuantityToConsignmentConsumptionPositions < ActiveRecord::Migration[7.1]
  def change
    add_column :consignment_consumption_positions, :current_quantity, :integer
  end
end
