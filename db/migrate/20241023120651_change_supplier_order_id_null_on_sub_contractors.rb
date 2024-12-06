class ChangeSupplierOrderIdNullOnSubContractors < ActiveRecord::Migration[7.1]
  def change
    change_column_null :sub_contractors, :supplier_order_id, true
  end
end
