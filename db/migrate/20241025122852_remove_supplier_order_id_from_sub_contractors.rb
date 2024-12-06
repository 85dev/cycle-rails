class RemoveSupplierOrderIdFromSubContractors < ActiveRecord::Migration[7.1]
  def change
    remove_column :sub_contractors, :supplier_order_id, :bigint
  end
end
