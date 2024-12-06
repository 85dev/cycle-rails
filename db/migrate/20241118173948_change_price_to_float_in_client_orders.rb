class ChangePriceToFloatInClientOrders < ActiveRecord::Migration[7.1]
  def change
    change_column :client_orders, :price, :float
  end
end
