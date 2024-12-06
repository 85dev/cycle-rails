class AddSortedToClientPositions < ActiveRecord::Migration[7.1]
  def change
    add_column :client_positions, :sorted, :boolean
  end
end
