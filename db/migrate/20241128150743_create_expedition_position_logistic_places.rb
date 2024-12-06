class CreateExpeditionPositionLogisticPlaces < ActiveRecord::Migration[7.1]
  def change
    create_join_table :expedition_positions, :logistic_places do |t|
      t.index [:expedition_position_id, :logistic_place_id]
      t.index [:logistic_place_id, :expedition_position_id]
    end
  end
end
