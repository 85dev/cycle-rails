class AddPriceToExpeditions < ActiveRecord::Migration[7.1]
  def change
    add_column :expeditions, :price, :decimal
  end
end
