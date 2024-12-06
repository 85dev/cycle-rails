class CreateJoinTableStockPlacesOrderPositions < ActiveRecord::Migration[7.1]
  def change
    create_join_table :logistic_places, :order_positions do |t|
      t.index [:logistic_place_id, :order_position_id]
      t.index [:order_position_id, :logistic_place_id]
    end
  end
end
