class AddStatusToSupplierOrder < ActiveRecord::Migration[7.1]
  def change
    add_column :supplier_orders, :status, :string
  end
end
