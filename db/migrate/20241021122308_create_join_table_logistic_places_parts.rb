class CreateJoinTableLogisticPlacesParts < ActiveRecord::Migration[7.1]
  def change
    create_join_table :logistic_places, :parts do |t|
      t.index [:logistic_place_id, :part_id]
      t.index [:part_id, :logistic_place_id]
    end
  end
end
