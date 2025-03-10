Rails.application.routes.draw do
  devise_for :users,
    controllers: {
      sessions: 'users/sessions',
      registrations: 'users/registrations'
    }

  # Account, request access and authentication routes
  get '/member_data', to: 'members#show'
  get 'users/check_email', to: 'members#check_email'
  post 'users/reset_password', to: 'members#reset_user_password'
  post 'users/send_verification_email', to: 'members#send_verification_email'
  post 'users/verify_access_code', to: 'members#verify_access_code'
  post 'users/verify_unconfirmed_user_access_code', to: 'members#verify_unconfirmed_user_access_code'
  post 'users/request_user_access_code', to: 'members#request_user_access_code'
  get 'accounts/:user_id/validated_companies_accounts', to: 'members#fetch_validated_companies_accounts'
  get 'accounts/:user_id/companies/:company_id/request_access', to: 'members#request_access_to_company'
  get 'accounts/:user_id/pending_requests', to: 'members#fetch_pending_requests'
  get 'accounts/:user_id/access_requests', to: 'members#fetch_access_requests'
  get 'accounts/:user_id/companies/:company_id/fetch_account', to: 'members#fetch_account'
  patch 'accounts/:account_id/users/:user_id/validate_access_request', to: 'members#validate_access_request'
  get 'companies/:company_id/users', to: 'members#fetch_users_for_company'
  patch 'accounts/:user_id/companies/:company_id/reject', to: 'members#reject_access_request'
  post 'users/:user_id/send_access_request', to: 'members#send_user_account_authorization'

  # Statistis GET routes
  get 'companies/:company_id/parts_sold_by_month', to: 'parts#fetch_parts_sold_by_month'
  get 'companies/:company_id/sales_distribution', to: 'parts#fetch_sales_distribution'
  get 'companies/:company_id/revenue_vs_costs', to: 'parts#fetch_revenue_vs_costs'
  get 'companies/:company_id/margins_by_part', to: 'parts#fetch_margins_by_part'
  get 'companies/:company_id/parts_stocks', to: 'parts#fetch_all_parts_stocks'

  # Consumptions GET routes
  get 'clients/:client_id/consignment_stocks/:consignment_stock_id/consumptions_by_consignment_stock', to: 'parts#fetch_consumptions_by_consignment_stock'

  # Separate GET fetch routes for related data
  get 'companies/search_company_by_name', to: 'parts#search_company_by_name'
  get 'companies/:company_id/clients/:client_id/stocks_by_client', to: 'parts#fetch_stocks_by_client'
  get 'companies/:company_id/client_by_name', to: 'parts#fetch_client_by_name'
  get 'companies/:company_id/client_orders_by_company', to: 'parts#fetch_client_orders_by_company'
  get 'companies/:company_id/supplier_orders_by_company', to: 'parts#fetch_supplier_orders_by_company'
  get 'companies/:company_id/part_related_data/:part_id', to: 'parts#part_related_data'
  get 'companies/:company_id/parts', to: 'parts#parts_by_company'
  get 'companies/:company_id/suppliers/:supplier_id/parts_by_supplier', to: 'parts#fetch_parts_by_supplier'
  get 'companies/:company_id/expeditions/:expedition_id/supplier_orders', to: 'parts#fetch_expedition_orders'
  get 'companies/:company_id/parts/:part_id/supplier_orders', to: 'parts#fetch_supplier_orders_by_part'
  get 'companies/:company_id/parts/:part_id/client_order_positions', to: 'parts#fetch_client_order_positions_by_part'
  get 'companies/:company_id/future_company_client_orders', to: 'parts#fetch_future_company_client_orders'
  get 'companies/:company_id/parts/:part_id/supplier_order_indices_by_part', to: 'parts#fetch_expeditions_supplier_order_indices_by_part'
  get 'companies/:company_id/parts/:part_id/sub_contractors', to: 'parts#fetch_sub_contractors_by_part'
  get 'companies/:company_id/parts/:part_id/logistic_places', to: 'parts#fetch_logistic_places_by_part'
  get 'companies/:company_id/parts/:part_id/supplier_orders_positions', to: 'parts#fetch_supplier_orders_positions_by_company_and_part'
  get 'companies/:company_id/company_uncompleted_supplier_orders_positions', to: 'parts#fetch_uncompleted_supplier_orders_positions_by_company'
  get 'companies/:company_id/undelivered_expeditions', to: 'parts#fetch_undelivered_expeditions'
  get 'companies/:company_id/delivered_expeditions', to: 'parts#fetch_delivered_expeditions'
  get 'companies/:company_id/parts/:part_id/expedition_position_by_sub_contractor', to: 'parts#fetch_expedition_position_by_sub_contractor'
  get 'companies/:company_id/parts/:part_id/expedition_position_by_logistic_place', to: 'parts#fetch_expedition_position_by_logistic_place'
  get 'companies/:company_id/clients_by_part_ids', to: 'parts#clients_by_part_ids'
  get 'companies/:company_id/parts/:part_id/unsorted_client_positions', to: 'parts#fetch_unsorted_client_positions'
  get 'companies/:company_id/clients/:client_id/fetch_standard_stocks_by_client', to: 'parts#fetch_standard_stocks_by_client'
  get 'companies/:company_id/clients/:client_id/fetch_consignment_stocks_by_client', to: 'parts#fetch_consignment_stocks_by_client'
  get 'companies/:company_id/parts/:part_id/clients/:client_id/standard_stocks_positions_by_client', to: 'parts#standard_stocks_positions_by_client'
  get 'companies/:company_id/parts/:part_id/clients/:client_id/consignment_stocks_positions_by_client', to: 'parts#consignment_stocks_positions_by_client'
  get 'companies/:company_id/clients/:client_id/parts_by_client', to: 'parts#fetch_parts_by_client'
  get 'companies/:company_id/clients/:client_id/contacts_by_client', to: 'parts#fetch_contacts_by_client'
  get 'companies/:company_id/supplier_orders/:supplier_order_id/contacts_by_supplier_order', to: 'parts#fetch_contacts_by_supplier_order'
  get 'companies/:company_id/client_positions/:client_position_id/position_history', to: 'parts#fetch_position_history'
  get 'companies/:company_id/kpi_metrics', to: 'parts#fetch_kpi_metrics'
  get 'companies/:company_id/clients/:client_id/consignment_stocks/:consignment_stock_id/parts_by_client_and_consignment_stock', to: 'parts#fetch_parts_by_client_and_consignment_stock'
  get 'companies/:company_id/parts/:part_id/calculate_part_stocks', to: 'parts#fetch_calculate_part_stocks'
  get 'companies/:company_id/delivery_slips_by_company', to: 'parts#fetch_delivery_slips_by_company'
  get 'companies/:company_id/order_slips_by_company', to: 'parts#fetch_order_slips_by_company'
  get 'companies/:company_id/clients/:client_id/client_orders_by_client', to: 'parts#fetch_client_orders_by_client'
  get 'companies/:company_id/clients/:client_id/expedition_positions_by_client', to: 'parts#fetch_expedition_positions_by_client'

  # Routes to DELETE or ARCHIVE items
  get 'companies/:company_id/client_orders/:client_order_id', to: 'parts#archive_client_order'
  get 'companies/:company_id/supplier_orders/:supplier_order_id', to: 'parts#archive_supplier_order'
  delete 'companies/:company_id/parts/:id', to: 'parts#delete_part'
  get 'companies/:company_id/archive_expedition_position/:expedition_position_id', to: 'parts#archive_expedition_position'
  get 'companies/:company_id/archive_client_position/:client_position_id', to: 'parts#archive_client_position'

  # Route POST & GET for creating and updating models
  post 'users/:user_id/companies', to: 'parts#create_company'
  post 'companies/:company_id/transporter', to: 'parts#create_transporter'
  post 'companies/:company_id/clients/:client_id/create_client_order', to: 'parts#create_client_order'
  post 'companies/:company_id/suppliers/:supplier_id/create_supplier_order', to: 'parts#create_supplier_order'
  post 'companies/:company_id/parts', to: 'parts#create_part'
  post 'companies/:company_id/create_client', to: 'parts#create_client'
  post 'companies/:company_id/create_expedition', to: 'parts#create_expedition'
  post 'companies/:company_id/create_supplier', to: 'parts#create_supplier'
  post 'companies/:company_id/create_sub_contractor', to: "parts#create_sub_contractor"
  post 'companies/:company_id/create_logistic_place', to: "parts#create_logistic_place"
  post 'companies/:company_id/expeditions/:expedition_id/dispatch_expedition', to: 'parts#dispatch_expedition'
  post 'companies/:company_id/clients/:client_id/sort_client_positions', to: 'parts#sort_client_positions'
  post 'companies/:company_id/expedition_positions/:expedition_position_id/transfer_position', to: 'parts#transfer_position'
  post 'companies/:company_id/client_positions/:client_position_id/transfer_position_from_client',to: 'parts#transfer_position_from_client'
  post 'companies/:company_id/consignment_stocks/:consignment_stock_id/create_consignment_consumption', to: 'parts#create_consignment_consumption'
  patch 'companies/:company_id/client_order_positions/:position_id/complete_client_order', to: 'parts#complete_client_order_position'
  patch 'companies/:company_id/supplier_order_positions/:position_id/complete_supplier_order', to: 'parts#complete_supplier_order_position'
  
  # Routes GET for data index by user
  get 'companies/:company_id/clients', to: 'parts#client_index'
  get 'companies/:company_id/suppliers', to: 'parts#supplier_index'
  get 'companies/:company_id/supplier_orders', to: 'parts#fetch_supplier_orders_by_company'
  get 'companies/:company_id/expeditions', to: 'parts#expeditions_by_company'
  get 'companies/:company_id/subcontractors_index', to: 'parts#subcontractors_index'
  get 'companies/:company_id/logistic_places', to: 'parts#logistic_places_index'
  get 'companies/:company_id/transporters_index', to: 'parts#transporters_index_by_company'
  get 'users/:user_id/companies_index', to: 'parts#companies_index'
  get 'users/:user_id/owner_companies_index', to: 'parts#owner_companies_index'

  # Routes GET/POST for generating, updating and fetching PDF and models dedicated to PDF generation
  post 'companies/:company_id/delivery_slip', to: 'pdf_generator#create_delivery_slip'
  get 'pdf_generator/:delivery_slip_id/generate_delivery_slip_pdf', to: 'pdf_generator#generate_delivery_slip_pdf'
  get 'pdf_generator/:order_slip_id/generate_order_slip_single_position_pdf', to: 'pdf_generator#generate_order_slip_single_position_pdf'
  post 'pdf_generator/:supplier_order_position_id/order_slip_single_position', to: 'pdf_generator#order_slip_single_position'
  post 'pdf_generator/:supplier_order_id/order_slip_multiple_positions', to: 'pdf_generator#order_slip_multiple_positions'
  get 'pdf_generator/:client_id/last_delivery_slip', to: 'pdf_generator#fetch_last_delivery_slip_by_client'

  # Health check route

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
