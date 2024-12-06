class ChangeNumberTypeInClientOrders < ActiveRecord::Migration[7.1]
  def change
    change_column :client_orders, :number, :string
  end
end
