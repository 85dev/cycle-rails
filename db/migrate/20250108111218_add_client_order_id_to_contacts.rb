class AddClientOrderIdToContacts < ActiveRecord::Migration[7.1]
  def change
    add_reference :client_orders, :contact, null: true, foreign_key: true
  end
end
