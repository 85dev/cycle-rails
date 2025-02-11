class AddTransitMethodsToOrderSlips < ActiveRecord::Migration[7.1]
  def change
    add_column :order_slips, :is_boat, :boolean
    add_column :order_slips, :is_flight, :boolean
    add_column :order_slips, :is_train, :boolean
  end
end
