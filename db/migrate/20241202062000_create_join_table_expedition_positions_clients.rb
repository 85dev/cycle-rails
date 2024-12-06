class CreateJoinTableExpeditionPositionsClients < ActiveRecord::Migration[7.1]
  def change
    create_join_table :expedition_positions, :clients do |t|
      t.index [:expedition_position_id, :client_id]
      t.index [:client_id, :expedition_position_id]
    end
  end
end
