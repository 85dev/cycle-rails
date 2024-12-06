class AddClientContactToClientOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :client_orders, :client_contact, :string
  end
end
