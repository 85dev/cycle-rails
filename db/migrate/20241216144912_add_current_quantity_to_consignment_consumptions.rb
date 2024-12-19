class AddCurrentQuantityToConsignmentConsumptions < ActiveRecord::Migration[7.1]
  def change
    add_column :consignment_consumptions, :current_quantity, :integer
  end
end
