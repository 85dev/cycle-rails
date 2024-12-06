class ChangeReferencesToNullableForSupplierOrderIndexInClientPosition < ActiveRecord::Migration[7.1]
  def change
    change_column :client_positions, :supplier_order_index_id, :bigint, null: true
  end
end
