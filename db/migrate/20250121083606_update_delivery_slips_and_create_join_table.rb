class UpdateDeliverySlipsAndCreateJoinTable < ActiveRecord::Migration[7.1]
  def change
    remove_reference :delivery_slips, :client_order, index: true, foreign_key: true
  end
end
