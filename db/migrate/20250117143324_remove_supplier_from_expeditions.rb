class RemoveSupplierFromExpeditions < ActiveRecord::Migration[7.1]
  def change
    remove_reference :expeditions, :supplier, index: true, foreign_key: true
  end
end
