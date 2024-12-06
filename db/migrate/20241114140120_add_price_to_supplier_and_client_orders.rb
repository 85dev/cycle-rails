class AddPriceToSupplierAndClientOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :supplier_orders, :price, :integer
    add_column :client_orders, :price, :integer
  end
end
