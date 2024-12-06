class RemovePartIdFromLogisticPlaces < ActiveRecord::Migration[7.1]
  def change
    remove_column :logistic_places, :part_id, :bigint
  end
end
