class RemoveSubcontractorIdAndLogisticPlaceIdFromExpeditionPositions < ActiveRecord::Migration[7.1]
  def change
    remove_reference :expedition_positions, :sub_contractor, foreign_key: true
    remove_reference :expedition_positions, :logistic_place, foreign_key: true
  end
end
