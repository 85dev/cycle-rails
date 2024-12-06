class AddInvoiceFieldsToClientOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :client_orders, :invoice_issued, :boolean, default: false
    add_column :client_orders, :invoice_paid, :boolean, default: false
  end
end