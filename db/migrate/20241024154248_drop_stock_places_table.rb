class DropStockPlacesTable < ActiveRecord::Migration[7.1]
  def change
    drop_table :stock_places
  end
end
