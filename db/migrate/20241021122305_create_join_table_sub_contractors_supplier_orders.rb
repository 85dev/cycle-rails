class CreateJoinTableSubContractorsSupplierOrders < ActiveRecord::Migration[7.1]
  def change
    create_join_table :sub_contractors, :supplier_orders do |t|
      t.index [:sub_contractor_id, :supplier_order_id]
      t.index [:supplier_order_id, :sub_contractor_id]
    end
  end
end
