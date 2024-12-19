Rails.application.routes.draw do
  devise_for :users,
    controllers: {
      sessions: 'users/sessions',
      registrations: 'users/registrations'
    }

  # Specific routes
  get '/member-data', to: 'members#show'
  get 'users/:user_id/part_related_data/:part_id', to: 'parts#part_related_data'
  get 'users/:user_id/parts', to: 'parts#parts_by_user'
  get 'users/:user_id/expeditions/:expedition_id/supplier_orders', to: 'parts#fetch_expedition_orders'

  # Separate GET fetch routes for related data
  get 'users/:user_id/parts/:part_id/supplier_orders', to: 'parts#fetch_supplier_orders_by_part'
  get 'users/:user_id/parts/:part_id/client_orders', to: 'parts#fetch_client_orders_by_part'
  get 'users/:user_id/future_user_client_orders', to: 'parts#fetch_future_user_client_orders'
  get 'users/:user_id/parts/:part_id/supplier_order_indexes_by_part', to: 'parts#fetch_expeditions_supplier_order_indices_by_part'
  get 'users/:user_id/parts/:part_id/sub_contractors', to: 'parts#fetch_sub_contractors_by_part'
  get 'users/:user_id/parts/:part_id/logistic_places', to: 'parts#fetch_logistic_places_by_part'
  get 'users/:user_id/parts/:part_id/supplier_orders_positions', to: 'parts#fetch_supplier_orders_positions_by_user_and_part'
  get 'users/:user_id/user_uncompleted_supplier_orders_positions', to: 'parts#fetch_uncompleted_supplier_orders_positions_by_user'
  get 'users/:user_id/undelivered_expeditions', to: 'parts#fetch_undelivered_expeditions'
  get 'users/:user_id/delivered_expeditions', to: 'parts#fetch_delivered_expeditions'
  get 'users/:user_id/parts/:part_id/expedition_position_by_sub_contractor', to: 'parts#fetch_expedition_position_parts_by_sub_contractor'
  get 'users/:user_id/parts/:part_id/expedition_position_by_logistic_place', to: 'parts#fetch_expedition_position_parts_by_logistic_place'
  get 'users/:user_id/clients_by_part_ids', to: 'parts#clients_by_part_ids'
  get 'users/:user_id/parts/:part_id/unsorted_client_positions', to: 'parts#fetch_unsorted_client_positions'
  get 'users/:user_id/clients/:client_id/fetch_standard_stocks_by_client', to: 'parts#fetch_standard_stocks_by_client'
  get 'users/:user_id/clients/:client_id/fetch_consignment_stocks_by_client', to: 'parts#fetch_consignment_stocks_by_client'
  get 'users/:user_id/parts/:part_id/clients/:client_id/standard_stocks_positions_by_client', to: 'parts#standard_stocks_positions_by_client'
  get 'users/:user_id/parts/:part_id/clients/:client_id/consignment_stocks_positions_by_client', to: 'parts#consignment_stocks_positions_by_client'
  get 'users/:user_id/clients/:client_id/parts_by_client', to: 'parts#fetch_parts_by_client'
  get 'users/:user_id/parts/:part_id/part_history', to: 'parts#fetch_part_history'
  get 'users/:user_id/client_positions/:client_position_id/position_history', to: 'parts#fetch_position_history'
  get 'users/:user_id/kpi_metrics', to: 'parts#fetch_kpi_metrics'
  get 'users/:user_id/clients/:client_id/consignment_stocks/:consignment_stock_id/parts_by_client_and_consignment_stock', to: 'parts#fetch_parts_by_client_and_consignment_stock'
  
  # Route DELETE for deleting orders
  delete 'users/:user_id/client_orders/:client_order_id', to: 'parts#delete_client_order'
  delete 'users/:user_id/supplier_orders/:supplier_order_id', to: 'parts#delete_supplier_order'
  delete 'users/:user_id/parts/:id', to: 'parts#delete_part'

  # Route POST for creating and updating models
  post 'users/:user_id/clients/:client_id/create_client_order', to: 'parts#create_client_order'
  post 'users/:user_id/suppliers/:supplier_id/create_supplier_order', to: 'parts#create_supplier_order'
  post 'users/:user_id/parts', to: 'parts#create_part'
  post 'users/:user_id/create_client', to: 'parts#create_client'
  post 'users/:user_id/create_expedition', to: 'parts#create_expedition'
  post 'users/:user_id/create_supplier', to: 'parts#create_supplier'
  post 'users/:user_id/create_sub_contractor', to: "parts#create_subcontractor"
  post 'users/:user_id/create_logistic_place', to: "parts#create_logistic_place"
  post 'users/:user_id/expeditions/:expedition_id/dispatch_expedition', to: 'parts#dispatch_expedition'
  post 'users/:user_id/clients/:client_id/sort_client_positions', to: 'parts#sort_client_positions'
  post 'users/:user_id/expedition_positions/:expedition_position_id/transfer_position', to: 'parts#transfer_position'
  post 'users/:user_id/consignment_stocks/:consignment_stock_id/create_consignment_consumption', to: 'parts#create_consignment_consumption'
  # Get is enough for this route
  get 'users/:user_id/client_orders/:client_order_id/complete_client_order', to: 'parts#complete_client_order'

  # Routes GET for data index by user
  get 'users/:user_id/clients', to: 'parts#client_index'
  get 'users/:user_id/suppliers', to: 'parts#supplier_index'
  get 'users/:user_id/supplier_orders', to: 'parts#fetch_supplier_orders_by_user'
  get 'users/:user_id/expeditions', to: 'parts#expeditions'
  get 'users/:user_id/subcontractors_index', to: 'parts#subcontractors_index'
  get 'users/:user_id/logistic_places', to: 'parts#logistic_places_index'

  # Health check route

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
