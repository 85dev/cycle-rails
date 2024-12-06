class RemoveOrderableFromOrderPositions < ActiveRecord::Migration[7.1]
  def change
    remove_column :order_positions, :orderable_type, :string
    remove_column :order_positions, :orderable_id, :bigint
  end
end
