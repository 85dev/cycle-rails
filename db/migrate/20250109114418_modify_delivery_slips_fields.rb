class ModifyDeliverySlipsFields < ActiveRecord::Migration[7.1]
  def change
    change_column_null :delivery_slips, :client_order_id, true
    change_column_null :delivery_slips, :part_id, true
    change_column_null :delivery_slips, :company_id, true
    change_column_null :delivery_slips, :expedition_position_id, true
    change_column_null :delivery_slips, :contact_id, true

    add_column :delivery_slips, :departure_address, :string
    add_column :delivery_slips, :arrival_address, :string
  end
end
