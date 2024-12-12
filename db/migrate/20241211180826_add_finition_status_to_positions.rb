class AddFinitionStatusToPositions < ActiveRecord::Migration[7.1]
  def change
    add_column :supplier_order_indices, :finition_status, :string, default: 'draft'
    add_column :client_positions, :finition_status, :string, default: 'draft'
    add_column :expedition_positions, :finition_status, :string, default: 'draft'
  end
end
