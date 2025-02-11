class AddEmissionDateToSupplierOrder < ActiveRecord::Migration[7.1]
  def change
    add_column :supplier_orders, :emission_date, :datetime
  end
end
