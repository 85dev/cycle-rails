class AddCloneToClientAndExpeditionPositions < ActiveRecord::Migration[7.1]
  def change
    add_column :client_positions, :is_clone, :boolean, default: false, null: false
    add_column :expedition_positions, :is_clone, :boolean, default: false, null: false
  end
end
