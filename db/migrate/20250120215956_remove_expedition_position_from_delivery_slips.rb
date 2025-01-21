class RemoveExpeditionPositionFromDeliverySlips < ActiveRecord::Migration[7.1]
  def change
    remove_reference :delivery_slips, :expedition_position, foreign_key: true
  end
end
