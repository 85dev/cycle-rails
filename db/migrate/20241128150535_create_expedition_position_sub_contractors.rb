class CreateExpeditionPositionSubContractors < ActiveRecord::Migration[7.1]
  def change
    create_join_table :expedition_positions, :sub_contractors do |t|
      t.index [:expedition_position_id, :sub_contractor_id]
      t.index [:sub_contractor_id, :expedition_position_id]
    end
  end
end
