class AddSupplierToExpeditions < ActiveRecord::Migration[7.1]
  def change
    add_reference :expeditions, :supplier, null: false, foreign_key: true
  end
end
