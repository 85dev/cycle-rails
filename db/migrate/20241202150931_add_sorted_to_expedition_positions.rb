class AddSortedToExpeditionPositions < ActiveRecord::Migration[7.1]
  def change
    add_column :expedition_positions, :sorted, :boolean
  end
end
