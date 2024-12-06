class CreateClientPositionsExpeditionsJoinTable < ActiveRecord::Migration[7.1]
  def change
    create_join_table :expeditions, :client_positions do |t|
      t.index [:expedition_id, :client_position_id]
      t.index [:client_position_id, :expedition_id]
    end
  end
end
