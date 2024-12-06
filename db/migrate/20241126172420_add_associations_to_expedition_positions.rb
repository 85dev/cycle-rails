class AddAssociationsToExpeditionPositions < ActiveRecord::Migration[7.1]
  def change
    add_reference :expedition_positions, :sub_contractor, null: false, foreign_key: true
    add_reference :expedition_positions, :logistic_place, null: false, foreign_key: true
  end
end
