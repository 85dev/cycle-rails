class AddSupplierOrderIdToContacts < ActiveRecord::Migration[7.1]
  def change
    add_reference :supplier_orders, :contact, null: true, foreign_key: true
  end
end
