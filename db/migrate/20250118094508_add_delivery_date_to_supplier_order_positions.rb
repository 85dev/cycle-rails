class AddDeliveryDateToSupplierOrderPositions < ActiveRecord::Migration[7.1]
  def change
    add_column :supplier_order_positions, :real_delivery_date, :date
  end
end
