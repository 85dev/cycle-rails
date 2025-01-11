class CleanClientOrders < ActiveRecord::Migration[7.1]
  def change
    change_table :client_orders do |t|
      # Remove unnecessary fields
      t.remove :order_delivery_time
      t.remove :estimated_arrival_time
      t.remove :estimated_departure_time
      t.remove :reel_delivery_time
      t.remove :reel_arrival_time

      # Add new field
      t.date :delivery_date
    end
  end
end
