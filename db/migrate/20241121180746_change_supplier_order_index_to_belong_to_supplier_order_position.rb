class ChangeSupplierOrderIndexToBelongToSupplierOrderPosition < ActiveRecord::Migration[7.1]
  def change
     # Remove the existing supplier_order reference
     remove_reference :supplier_order_indices, :supplier_order, foreign_key: true

     # Add the new supplier_order_position reference
     add_reference :supplier_order_indices, :supplier_order_position, null: false, foreign_key: true
  end
end
