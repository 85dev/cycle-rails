class UpdateExpeditionRelationshipInClientPositions < ActiveRecord::Migration[7.1]
  def change
    # Remove the existing join table
    drop_table :client_positions_expeditions, if_exists: true

    # Add a foreign key to client_positions pointing to expeditions
    add_reference :client_positions, :expedition, foreign_key: true
  end
end
