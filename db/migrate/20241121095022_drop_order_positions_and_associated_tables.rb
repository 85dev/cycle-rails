class DropOrderPositionsAndAssociatedTables < ActiveRecord::Migration[7.1]
  def change
    drop_table :client_orders_order_positions, if_exists: true do |t|
      t.bigint :client_order_id, null: false
      t.bigint :order_position_id, null: false
    end

    drop_table :logistic_places_order_positions, if_exists: true do |t|
      t.bigint :logistic_place_id, null: false
      t.bigint :order_position_id, null: false
    end

    drop_table :order_positions_parts, if_exists: true do |t|
      t.bigint :order_position_id, null: false
      t.bigint :part_id, null: false
    end

    drop_table :order_positions_sub_contractors, if_exists: true do |t|
      t.bigint :sub_contractor_id, null: false
      t.bigint :order_position_id, null: false
    end

    drop_table :order_positions_supplier_orders, if_exists: true do |t|
      t.bigint :supplier_order_id, null: false
      t.bigint :order_position_id, null: false
    end

    # Finally, drop the `order_positions` table
    drop_table :order_positions, if_exists: true do |t|
      t.integer :quantity
      t.datetime :real_departure_time
      t.datetime :estimated_departure_time
      t.integer :position
    end
  end
end
