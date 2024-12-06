class ChangePriceToFloatInSupplierOrders < ActiveRecord::Migration[7.1]
  def change
    change_column :supplier_orders, :price, :float
  end
end
