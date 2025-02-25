class AddArchivedToExpeditionAndClientPositions < ActiveRecord::Migration[7.1]
  def change
    add_column :expedition_positions, :archived, :boolean, default: false
    add_column :client_positions, :archived, :boolean, default: false
  end
end
