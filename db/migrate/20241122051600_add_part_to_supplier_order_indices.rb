class AddPartToSupplierOrderIndices < ActiveRecord::Migration[7.1]
  def change
    add_reference :supplier_order_indices, :part, null: false, foreign_key: true
  end
end
