class AddPriceToPart < ActiveRecord::Migration[7.1]
  def change
    add_column :parts, :price, :integer
  end
end
