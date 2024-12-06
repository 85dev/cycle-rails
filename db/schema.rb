# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_12_06_123637) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "client_order_positions", force: :cascade do |t|
    t.bigint "client_order_id", null: false
    t.bigint "part_id", null: false
    t.integer "quantity"
    t.float "price"
    t.datetime "delivery_date"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_order_id"], name: "index_client_order_positions_on_client_order_id"
    t.index ["part_id"], name: "index_client_order_positions_on_part_id"
  end

  create_table "client_orders", force: :cascade do |t|
    t.bigint "client_id", null: false
    t.string "transporter"
    t.integer "quantity"
    t.string "order_status", default: "undelivered", null: false
    t.datetime "order_date"
    t.datetime "order_delivery_time"
    t.datetime "estimated_arrival_time"
    t.datetime "estimated_departure_time"
    t.datetime "reel_delivery_time"
    t.datetime "reel_arrival_time"
    t.string "number"
    t.string "batch"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "client_contact"
    t.float "price"
    t.boolean "invoice_issued", default: false
    t.boolean "invoice_paid", default: false
    t.index ["client_id"], name: "index_client_orders_on_client_id"
  end

  create_table "client_orders_parts", id: false, force: :cascade do |t|
    t.bigint "client_order_id", null: false
    t.bigint "part_id", null: false
  end

  create_table "client_orders_supplier_order_positions", id: false, force: :cascade do |t|
    t.bigint "supplier_order_position_id", null: false
    t.bigint "client_order_id", null: false
    t.index ["client_order_id", "supplier_order_position_id"], name: "idx_on_client_order_id_supplier_order_position_id_cb78b8de1c"
    t.index ["supplier_order_position_id", "client_order_id"], name: "idx_on_supplier_order_position_id_client_order_id_2b101bf23f"
  end

  create_table "client_orders_supplier_orders", id: false, force: :cascade do |t|
    t.bigint "client_order_id", null: false
    t.bigint "supplier_order_id", null: false
    t.index ["client_order_id", "supplier_order_id"], name: "idx_on_client_order_id_supplier_order_id_ebf2eb4dff"
    t.index ["supplier_order_id", "client_order_id"], name: "idx_on_supplier_order_id_client_order_id_c04d2d7cd9"
  end

  create_table "client_positions", force: :cascade do |t|
    t.bigint "client_id", null: false
    t.bigint "part_id", null: false
    t.integer "quantity"
    t.string "location"
    t.boolean "consignment_stock"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "sorted"
    t.bigint "expedition_id"
    t.bigint "supplier_order_index_id"
    t.boolean "is_clone", default: false, null: false
    t.index ["client_id"], name: "index_client_positions_on_client_id"
    t.index ["expedition_id"], name: "index_client_positions_on_expedition_id"
    t.index ["part_id"], name: "index_client_positions_on_part_id"
    t.index ["supplier_order_index_id"], name: "index_client_positions_on_supplier_order_index_id"
  end

  create_table "client_positions_consignment_stocks", id: false, force: :cascade do |t|
    t.bigint "client_position_id", null: false
    t.bigint "consignment_stock_id", null: false
    t.index ["client_position_id", "consignment_stock_id"], name: "idx_on_client_position_id_consignment_stock_id_a7fc0707db"
    t.index ["consignment_stock_id", "client_position_id"], name: "idx_on_consignment_stock_id_client_position_id_c2bbc01c4e"
  end

  create_table "client_positions_standard_stocks", id: false, force: :cascade do |t|
    t.bigint "client_position_id", null: false
    t.bigint "standard_stock_id", null: false
    t.index ["client_position_id", "standard_stock_id"], name: "idx_on_client_position_id_standard_stock_id_45a7d4acce"
    t.index ["standard_stock_id", "client_position_id"], name: "idx_on_standard_stock_id_client_position_id_2cf956c057"
  end

  create_table "clients", force: :cascade do |t|
    t.string "name"
    t.bigint "user_id", null: false
    t.string "address"
    t.string "country"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "contact_name"
    t.string "contact_email"
    t.index ["user_id"], name: "index_clients_on_user_id"
  end

  create_table "clients_expedition_positions", id: false, force: :cascade do |t|
    t.bigint "expedition_position_id", null: false
    t.bigint "client_id", null: false
    t.index ["client_id", "expedition_position_id"], name: "idx_on_client_id_expedition_position_id_4e0b98a38c"
    t.index ["expedition_position_id", "client_id"], name: "idx_on_expedition_position_id_client_id_1030e66625"
  end

  create_table "consignment_stocks", force: :cascade do |t|
    t.bigint "client_id", null: false
    t.string "address"
    t.string "contact_name"
    t.string "contact_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "current_quantity"
    t.index ["client_id"], name: "index_consignment_stocks_on_client_id"
  end

  create_table "expedition_positions", force: :cascade do |t|
    t.bigint "expedition_id", null: false
    t.bigint "supplier_order_index_id", null: false
    t.bigint "part_id", null: false
    t.integer "quantity", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "sorted"
    t.boolean "is_clone", default: false, null: false
    t.index ["expedition_id"], name: "index_expedition_positions_on_expedition_id"
    t.index ["part_id"], name: "index_expedition_positions_on_part_id"
    t.index ["supplier_order_index_id"], name: "index_expedition_positions_on_supplier_order_index_id"
  end

  create_table "expedition_positions_logistic_places", id: false, force: :cascade do |t|
    t.bigint "expedition_position_id", null: false
    t.bigint "logistic_place_id", null: false
    t.index ["expedition_position_id", "logistic_place_id"], name: "idx_on_expedition_position_id_logistic_place_id_91360bc4b9"
    t.index ["logistic_place_id", "expedition_position_id"], name: "idx_on_logistic_place_id_expedition_position_id_3d84e33726"
  end

  create_table "expedition_positions_sub_contractors", id: false, force: :cascade do |t|
    t.bigint "expedition_position_id", null: false
    t.bigint "sub_contractor_id", null: false
    t.index ["expedition_position_id", "sub_contractor_id"], name: "idx_on_expedition_position_id_sub_contractor_id_24a5b1cab8"
    t.index ["sub_contractor_id", "expedition_position_id"], name: "idx_on_sub_contractor_id_expedition_position_id_eb8adbff7b"
  end

  create_table "expeditions", force: :cascade do |t|
    t.datetime "estimated_departure_time"
    t.datetime "real_departure_time"
    t.datetime "arrival_time"
    t.string "transporter"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "supplier_id", null: false
    t.string "number"
    t.string "status"
    t.decimal "price"
    t.index ["supplier_id"], name: "index_expeditions_on_supplier_id"
  end

  create_table "expeditions_supplier_order_indices", id: false, force: :cascade do |t|
    t.bigint "expedition_id", null: false
    t.bigint "supplier_order_index_id", null: false
    t.index ["expedition_id", "supplier_order_index_id"], name: "idx_on_expedition_id_supplier_order_index_id_41691ab0a5"
    t.index ["supplier_order_index_id", "expedition_id"], name: "idx_on_supplier_order_index_id_expedition_id_2407045434"
  end

  create_table "jwt_denylist", force: :cascade do |t|
    t.string "jti", null: false
    t.datetime "exp", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["jti"], name: "index_jwt_denylist_on_jti", unique: true
  end

  create_table "logistic_places", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "contact_email"
    t.string "contact_name"
    t.index ["user_id"], name: "index_logistic_places_on_user_id"
  end

  create_table "logistic_places_parts", id: false, force: :cascade do |t|
    t.bigint "logistic_place_id", null: false
    t.bigint "part_id", null: false
  end

  create_table "logistic_places_supplier_orders", id: false, force: :cascade do |t|
    t.bigint "logistic_place_id", null: false
    t.bigint "supplier_order_id", null: false
  end

  create_table "parts", force: :cascade do |t|
    t.string "designation"
    t.string "reference"
    t.string "material"
    t.string "drawing"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "client_id", null: false
    t.integer "price"
    t.float "weight"
    t.index ["client_id"], name: "index_parts_on_client_id"
    t.index ["user_id"], name: "index_parts_on_user_id"
  end

  create_table "parts_sub_contractors", id: false, force: :cascade do |t|
    t.bigint "sub_contractor_id", null: false
    t.bigint "part_id", null: false
    t.index ["part_id"], name: "index_parts_sub_contractors_on_part_id"
    t.index ["sub_contractor_id"], name: "index_parts_sub_contractors_on_sub_contractor_id"
  end

  create_table "parts_supplier_orders", id: false, force: :cascade do |t|
    t.bigint "supplier_order_id", null: false
    t.bigint "part_id", null: false
  end

  create_table "parts_suppliers", id: false, force: :cascade do |t|
    t.bigint "supplier_id", null: false
    t.bigint "part_id", null: false
  end

  create_table "standard_stocks", force: :cascade do |t|
    t.bigint "client_id", null: false
    t.string "address"
    t.string "contact_name"
    t.string "contact_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "current_quantity"
    t.index ["client_id"], name: "index_standard_stocks_on_client_id"
  end

  create_table "sub_contractors", force: :cascade do |t|
    t.string "name"
    t.string "address"
    t.string "country"
    t.string "knowledge"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.string "contact_email"
    t.string "contact_name"
    t.index ["user_id"], name: "index_sub_contractors_on_user_id"
  end

  create_table "sub_contractors_supplier_orders", id: false, force: :cascade do |t|
    t.bigint "sub_contractor_id", null: false
    t.bigint "supplier_order_id", null: false
  end

  create_table "supplier_order_indices", force: :cascade do |t|
    t.integer "quantity"
    t.boolean "previsionnal"
    t.string "transporter"
    t.string "departure_address"
    t.string "arrival_address"
    t.datetime "order_date"
    t.datetime "order_delivery_time"
    t.datetime "estimated_arrival_time"
    t.datetime "estimated_departure_time"
    t.datetime "reel_delivery_time"
    t.datetime "reel_arrival_time"
    t.boolean "delivery_status"
    t.string "batch"
    t.string "quantity_status"
    t.string "status"
    t.string "number"
    t.boolean "partial"
    t.float "price"
    t.integer "shipped_quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "supplier_order_position_id", null: false
    t.bigint "part_id", null: false
    t.index ["part_id"], name: "index_supplier_order_indices_on_part_id"
    t.index ["supplier_order_position_id"], name: "index_supplier_order_indices_on_supplier_order_position_id"
  end

  create_table "supplier_order_indices_positions", id: false, force: :cascade do |t|
    t.bigint "supplier_order_index_id", null: false
    t.bigint "supplier_order_position_id", null: false
    t.index ["supplier_order_index_id", "supplier_order_position_id"], name: "idx_on_supplier_order_index_id_supplier_order_posit_d03a10ad6e"
    t.index ["supplier_order_position_id", "supplier_order_index_id"], name: "idx_on_supplier_order_position_id_supplier_order_in_e0d8a2fe47"
  end

  create_table "supplier_order_positions", force: :cascade do |t|
    t.bigint "supplier_order_id", null: false
    t.bigint "part_id", null: false
    t.float "price", null: false
    t.integer "quantity", null: false
    t.datetime "delivery_date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status"
    t.integer "original_quantity", default: 0, null: false
    t.string "quantity_status"
    t.index ["part_id"], name: "index_supplier_order_positions_on_part_id"
    t.index ["supplier_order_id"], name: "index_supplier_order_positions_on_supplier_order_id"
  end

  create_table "supplier_orders", force: :cascade do |t|
    t.bigint "supplier_id", null: false
    t.integer "quantity"
    t.boolean "previsionnal"
    t.string "transporter"
    t.string "departure_address"
    t.string "arrival_address"
    t.datetime "order_date"
    t.datetime "order_delivery_time"
    t.datetime "estimated_arrival_time"
    t.datetime "estimated_departure_time"
    t.datetime "reel_delivery_time"
    t.datetime "reel_arrival_time"
    t.boolean "delivery_status"
    t.string "number"
    t.string "batch"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "supplier_order_number"
    t.float "price"
    t.string "status"
    t.boolean "partial"
    t.boolean "invoice_paid", default: false
    t.integer "shipped_quantity"
    t.boolean "completed"
    t.integer "real_quantity"
    t.string "quantity_status"
    t.index ["supplier_id"], name: "index_supplier_orders_on_supplier_id"
  end

  create_table "suppliers", force: :cascade do |t|
    t.string "name"
    t.string "knowledge"
    t.bigint "user_id", null: false
    t.string "address"
    t.string "country"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "contact_name"
    t.string "contact_email"
    t.index ["user_id"], name: "index_suppliers_on_user_id"
  end

  create_table "transporters", force: :cascade do |t|
    t.string "name", null: false
    t.string "contact_name", null: false
    t.string "contact_email", null: false
    t.string "transport_type", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_transporters_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "client_order_positions", "client_orders"
  add_foreign_key "client_order_positions", "parts"
  add_foreign_key "client_orders", "clients"
  add_foreign_key "client_positions", "clients"
  add_foreign_key "client_positions", "expeditions"
  add_foreign_key "client_positions", "parts"
  add_foreign_key "client_positions", "supplier_order_indices"
  add_foreign_key "clients", "users"
  add_foreign_key "consignment_stocks", "clients"
  add_foreign_key "expedition_positions", "expeditions"
  add_foreign_key "expedition_positions", "parts"
  add_foreign_key "expedition_positions", "supplier_order_indices"
  add_foreign_key "expeditions", "suppliers"
  add_foreign_key "logistic_places", "users"
  add_foreign_key "parts", "clients"
  add_foreign_key "parts", "users"
  add_foreign_key "standard_stocks", "clients"
  add_foreign_key "sub_contractors", "users"
  add_foreign_key "supplier_order_indices", "parts"
  add_foreign_key "supplier_order_indices", "supplier_order_positions"
  add_foreign_key "supplier_order_positions", "parts"
  add_foreign_key "supplier_order_positions", "supplier_orders"
  add_foreign_key "supplier_orders", "suppliers"
  add_foreign_key "suppliers", "users"
  add_foreign_key "transporters", "users"
end
