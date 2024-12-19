class AddCurrentPricesToParts < ActiveRecord::Migration[7.1]
  def change
    add_column :parts, :current_client_price, :decimal
    add_column :parts, :current_supplier_price, :decimal
  end
end
