class CreateJoinTableSubContractorsOrderPositions < ActiveRecord::Migration[7.1]
  def change
    create_join_table :sub_contractors, :order_positions do |t|
      t.index [:sub_contractor_id, :order_position_id]
      t.index [:order_position_id, :sub_contractor_id]
    end
  end
end
