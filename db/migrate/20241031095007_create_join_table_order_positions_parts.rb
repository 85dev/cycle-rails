class CreateJoinTableOrderPositionsParts < ActiveRecord::Migration[7.1]
  def change
    create_join_table :order_positions, :parts do |t|
      t.index [:order_position_id, :part_id]
      t.index [:part_id, :order_position_id]
    end
  end
end
