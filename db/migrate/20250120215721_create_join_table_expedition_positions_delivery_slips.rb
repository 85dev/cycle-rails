class CreateJoinTableExpeditionPositionsDeliverySlips < ActiveRecord::Migration[7.1]
    def change
      create_join_table :expedition_positions, :delivery_slips do |t|
        t.index [:expedition_position_id, :delivery_slip_id]
        t.index [:delivery_slip_id, :expedition_position_id]
      end
  end
end
