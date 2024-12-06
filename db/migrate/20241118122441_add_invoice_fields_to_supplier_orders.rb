class AddInvoiceFieldsToSupplierOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :supplier_orders, :invoice_paid, :boolean, default: false
  end
end
