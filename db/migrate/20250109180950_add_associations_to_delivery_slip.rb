class AddAssociationsToDeliverySlip < ActiveRecord::Migration[7.1]
  def change
    add_reference :delivery_slips, :logistic_place, null: true, foreign_key: true
    add_reference :delivery_slips, :sub_contractor, null: true, foreign_key: true
    add_reference :delivery_slips, :client, null: true, foreign_key: true
  end
end
