class ChangeNumberTypeInSupplierOrders < ActiveRecord::Migration[7.1]
  def change
    change_column :supplier_orders, :number, :string
  end
end
