class PartsController < ApplicationController
    before_action :set_user, only: [:create_supplier, :subcontractors_index, :logistic_places_index, :expeditions, :parts_by_user, :fetch_supplier_orders_by_user, :create_client, :create_part, :client_index, :fetch_client_orders_by_part, :fetch_expeditions_supplier_order_indices_by_part, :fetch_logistic_places_by_part, :fetch_sub_contractors_by_part, :fetch_supplier_orders_by_part]
    before_action :set_supplier, only: [:parts_by_supplier]
    before_action :set_client, only: [:parts_by_client, :standard_stocks_positions_by_client, :consignment_stocks_positions_by_client, :fetch_standard_stocks_by_client, :fetch_consignment_stocks_by_client]
    before_action :set_supplier_orders, only: [:parts_by_supplier_orders]
    before_action :set_client_orders, only: [:parts_by_client_orders]
    before_action :set_part, only: [:fetch_client_orders_by_part, :standard_stocks_positions_by_client, :consignment_stocks_positions_by_client, :fetch_unsorted_client_positions, :fetch_expeditions_supplier_order_indices_by_part, :fetch_logistic_places_by_part, :fetch_sub_contractors_by_part, :fetch_supplier_orders_by_part]
    before_action :set_expedition, only: [:fetch_expedition_orders, :dispatch_expedition]
    before_action :set_user_by_id, only: [:fetch_user_client_orders, :create_subcontractor, :create_logistic_place ]

    # API calls for models creation [POST]
    # Create PART linked to CLIENT, SUPPLIER and USER
    def create_part
      @client = Client.find_by(id: params[:client_id])
      @supplier = Supplier.find_by(id: params[:supplier_id])

      @part = @user.parts.new(part_params)
      @part.client = @client

      ActiveRecord::Base.transaction do
        if @part.save
          @part.suppliers << @supplier

          if params[:subcontractor_ids].present?
            subcontractors = SubContractor.where(id: params[:subcontractor_ids])
            @part.sub_contractors << subcontractors
          end

          render json: { success: 'Part created successfully', part: @part }, status: :created
        else
          render json: { errors: @part.errors.full_messages }, status: :unprocessable_entity
        end
      end
    end

    # Create CLIENT linked to USER along with its stocks
    def create_client
      ActiveRecord::Base.transaction do
        @client = @user.clients.new(client_params)

        if @client.save
          # Process consignment stocks
          if params[:client][:consignmentStocks]
            params[:client][:consignmentStocks].each do |stock_params|
              @client.consignment_stocks.create!(
                address: stock_params[:address],
                contact_name: stock_params[:contact_name],
                contact_email: stock_params[:contact_email]
              )
            end
          end

          # Process standard stocks
          if params[:client][:standardStocks]
            params[:client][:standardStocks].each do |stock_params|
              @client.standard_stocks.create!(
                address: stock_params[:address],
                contact_name: stock_params[:contact_name],
                contact_email: stock_params[:contact_email]
              )
            end
          end

          render json: { success: 'Client created successfully', client: @client, consignment_stocks: @client.consignment_stocks, standard_stocks: @client.standard_stocks }, status: :created
        else
          render json: { errors: @client.errors.full_messages }, status: :unprocessable_entity
        end
      end
    rescue ActiveRecord::RecordInvalid => e
      render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
    end

    # Create SUBCONTRACTOR linked to USER
    def create_subcontractor
      merged_params = subcontractor_params.merge(user: @user)

      @subcontractor = SubContractor.new(merged_params)

      if @subcontractor.save
        render json: { success: 'Subcontractor created successfully', subcontractor: @subcontractor }, status: :created
      else
        render json: { errors: @subcontractor.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # Create SUBCONTRACTOR linked to USER
    def create_logistic_place
      merged_params = logistic_place_params.merge(user: @user)

      @logistic_place = LogisticPlace.new(merged_params)

      if @logistic_place.save
        render json: { success: 'logistic_place created successfully', logistic_place: @logistic_place }, status: :created
      else
        render json: { errors: @logistic_place.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # Create CLIENT linked to USER
    def create_supplier
      @supplier = @user.suppliers.new(supplier_params)

      if @supplier.save
        render json: { success: 'supplier created successfully', supplier: @supplier }, status: :created
      else
        render json: { errors: @supplier.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # Create CLIENT_ORDER linked to CLIENT, PART
    def create_client_order
      @client_order = ClientOrder.new(client_order_params)
      @client_order.client = Client.find_by(id: params[:client_id])
      @client_order.order_status = 'undelivered'

      # Ensure client exists
      unless @client_order.client
        render json: { errors: "Client not found" }, status: :unprocessable_entity
        return
      end

      ActiveRecord::Base.transaction do
        if @client_order.save
          # Process order positions
          positions_data = params[:client_order][:order_positions]
          positions_data.each do |position|
            part = Part.find_by(id: position[:part_id])
    
            unless part
              render json: { errors: "Part not found for position" }, status: :unprocessable_entity
              raise ActiveRecord::Rollback
            end
    
            ClientOrderPosition.create!(
              client_order: @client_order,
              part: part,
              quantity: position[:quantity],
              price: position[:price],
              delivery_date: position[:delivery_date],
              status: 'undelivered'
            )
          end 

          render json: { success: "Client order created successfully", client_order: @client_order }, status: :created
        else
          render json: { errors: @client_order.errors.full_messages }, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: e.message }, status: :unprocessable_entity
      end
    end

    # Create SUPPLIER_ORDER linked to SUPPLIER, PART, CLIENT_ORDER
    def create_supplier_order
      # Initialize the SupplierOrder with params
      @supplier_order = SupplierOrder.new(supplier_order_params)
      @supplier_order.supplier = Supplier.find_by(id: params[:supplier_id])
      @supplier_order.status = 'production'
    
      # Parse client_order_ids from the query params
      client_order_ids = params[:client_order_ids]&.split(',') || []
    
      ActiveRecord::Base.transaction do
        if @supplier_order.save
          # Handle order_positions
          if params[:supplier_order][:order_positions]
            params[:supplier_order][:order_positions].each do |position|
              part = Part.find_by(id: position[:part_id])
    
              # Create SupplierOrderPosition for each position
              order_position = SupplierOrderPosition.create!(
                supplier_order: @supplier_order,
                part: part,
                price: position[:price],
                quantity: position[:quantity],
                original_quantity: position[:quantity],
                delivery_date: position[:delivery_date],
                status: 'production'
              )
    
              # Associate each order position with the respective client orders
              client_order_ids.each do |client_order_id|
                client_order = ClientOrder.find_by(id: client_order_id)
                order_position.client_orders << client_order if client_order
              end
            end
          end
    
          render json: { success: "Supplier order created successfully", supplier_order: @supplier_order }, status: :created
        else
          render json: { errors: @supplier_order.errors.full_messages }, status: :unprocessable_entity
        end
      end
    rescue ActiveRecord::RecordInvalid => e
      render json: { errors: e.message }, status: :unprocessable_entity
    end

    def create_expedition
      @expedition = Expedition.new(expedition_params)
      supplier = Supplier.find_by(id: params[:supplier_id])
      @expedition.supplier = supplier
    
      # Parse supplier order IDs, quantities, and partials from the URL parameters
      ids = params[:supplier_order_position_ids].split(',').map(&:strip)
      quantities = params[:supplier_order_position_quantities].split(',').map(&:strip).map(&:to_i)
      partials = params[:supplier_order_position_partials].split(',').map(&:strip).map { |p| ActiveModel::Type::Boolean.new.cast(p) }
    
      ActiveRecord::Base.transaction do
        if @expedition.save
          # Initial status of expedition
          @expedition.update!(status: 'undelivered')
          ids.each_with_index do |position_id, index|
            supplier_order_position = SupplierOrderPosition.find(position_id)
            shipped_quantity = quantities[index]
            is_partial = partials[index]

            total_delivered = supplier_order_position.quantity + shipped_quantity

             # Create a SupplierOrderIndex
            supplier_order_index = SupplierOrderIndex.create!(
              supplier_order_position: supplier_order_position,
              quantity: shipped_quantity,
              quantity_status: is_partial ? "partial" : "full",
              status: "transit",
              part: supplier_order_position.part
            )

            # Associate the SupplierOrderIndex with the Expedition
            @expedition.supplier_order_indices << supplier_order_index

            # Update the SupplierOrderPosition
            remaining_quantity = supplier_order_position.quantity - shipped_quantity

            new_status =
            if !is_partial
              "completed"
            elsif is_partial && remaining_quantity.positive?
              "partial_sent_and_production"
            else
              "production"
            end

            supplier_order_position.update!(
              quantity: remaining_quantity,
              status: new_status,
              quantity_status: total_delivered < supplier_order_position.original_quantity ? "partial" : "full"
            )
          end
          render json: { success: "Expedition created successfully", expedition: @expedition }, status: :created
        else
          render json: { errors: @expedition.errors.full_messages }, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: e.message }, status: :unprocessable_entity
      end
    end

    def dispatch_expedition      
      supplier_order_indices_ids = params[:supplier_order_indices_ids]
      subcontractors = params[:subcontractors]
      logistic_places = params[:logistic_places]
      references = params[:references]
      designations = params[:designations]
      clients = params[:clients]
      clones = params[:clones]
    
      ActiveRecord::Base.transaction do
        # Expedition update status to delivered
        expedition = Expedition.find_by(id: params[:expedition_id])

        # Process each dispatch
        supplier_order_indices_ids.each_with_index do |supplier_order_index_id, index|

          supplier_order_index = SupplierOrderIndex.find_by(id: supplier_order_index_id)

          subcontractor_name = subcontractors[index].presence
          logistic_place_name = logistic_places[index].presence
          part_reference = references[index]
          part_designation = designations[index]
          client_name = clients[index].presence
          is_clone = clones[index]

          part_id = Part.find_by(reference: part_reference, designation: part_designation)&.id
          raise ActiveRecord::RecordNotFound, "Part not found" unless part_id

          # Index set to delivered
          supplier_order_index.update!(status: 'delivered')

          if client_name
            # If the dispatch is to a client, create a ClientPosition
            client = Client.find_by(name: client_name)
            raise ActiveRecord::RecordNotFound, "Client not found" unless client
    
            client_position = ClientPosition.create!(
              client_id: client.id,
              supplier_order_index_id: supplier_order_index_id,
              expedition_id: expedition.id,
              part_id: part_id,
              quantity: supplier_order_index.quantity,
              is_clone: is_clone,
              sorted: false
            )
          else
            # Otherwise, create an ExpeditionPosition for subcontractor and logistic place destinations
            position = ExpeditionPosition.create!(
              supplier_order_index_id: supplier_order_index_id,
              expedition_id: expedition.id,
              part_id: part_id,
              is_clone: is_clone,
              quantity: supplier_order_index.quantity
            )
    
            # Handle subcontractors and logistic places for ExpeditionPosition
            if subcontractor_name
              subcontractor = SubContractor.find_by(name: subcontractor_name)
              position.sub_contractors << subcontractor if subcontractor
            end
    
            if logistic_place_name
              logistic_place = LogisticPlace.find_by(name: logistic_place_name)
              position.logistic_places << logistic_place if logistic_place
            end
          end
        end
    
        @expedition.update!(status: 'delivered')
    
        render json: { success: "Expedition dispatch completed successfully" }, status: :ok
      end
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

    def sort_client_positions
      client_position_ids = params[:client_position_ids]
      standard_stocks = params[:standard_stocks]
      consignment_stocks = params[:consignment_stocks]

      ActiveRecord::Base.transaction do
        client_position_ids.each_with_index do |client_position_id, index|
          client_position = ClientPosition.find_by(id: client_position_id)
    
          if standard_stocks[index] != 0
            standard_stock = StandardStock.find_by(id: standard_stocks[index])
            standard_stock.increment!(:current_quantity, client_position.quantity)

            client_position.standard_stocks << standard_stock
            client_position.update!(sorted: true, consignment_stock: false)
          elsif consignment_stocks[index] != 0
            consignment_stock = ConsignmentStock.find_by(id: consignment_stocks[index])
            consignment_stock.increment!(:current_quantity, client_position.quantity)

            client_position.consignment_stocks << consignment_stock
            client_position.update!(sorted: true, consignment_stock: true)
          end
        end
      end
    
      render json: { success: "Client positions sorted successfully" }, status: :ok
    rescue ActiveRecord::RecordNotFound => e
      render json: { error: e.message }, status: :not_found
    rescue ArgumentError => e
      render json: { error: e.message }, status: :unprocessable_entity
    rescue StandardError => e
      render json: { error: e.message }, status: :internal_server_error
    end

    def transfer_position
    expedition_position = ExpeditionPosition.find_by(id: params[:expedition_position_id])
    sub_contractor_id = params[:subContractorId]
    logistic_place_id = params[:logisticPlaceId]

      ActiveRecord::Base.transaction do
        case params[:destinationType]
        when "client"
          client = Client.find_by(name: params[:destinationName])
          if client
            ClientPosition.create!(
              client_id: client.id,
              part_id: params[:part_id],
              expedition_id: expedition_position.expedition_id,
              quantity: params[:quantity],
              sorted: false
            )
            render json: { success: "Position transferred to client successfully" }, status: :ok
          else
            render json: { error: "Client not found" }, status: :not_found
          end
        when "subcontractor"
          subcontractor = SubContractor.find_by(name: params[:destinationName])
          if subcontractor
            expedition_position.sub_contractors << subcontractor
            render json: { success: "Position transferred to subcontractor successfully" }, status: :ok
          else
            render json: { error: "Subcontractor not found" }, status: :not_found
          end
        when "logistic_place"
          logistic_place = LogisticPlace.find_by(name: params[:destinationName])
          if logistic_place
            expedition_position.logistic_places << logistic_place
            render json: { success: "Position transferred to logistic place successfully" }, status: :ok
          else
            render json: { error: "Logistic place not found" }, status: :not_found
          end
        else
          render json: { error: "Invalid destination type" }, status: :unprocessable_entity
        end

        if sub_contractor_id.present? && sub_contractor_id != 0
          sub_contractor = SubContractor.find_by(id: sub_contractor_id)

          expedition_position.sub_contractors.delete(sub_contractor)
        elsif logistic_place_id.present? && logistic_place_id != 0
          logistic_place = LogisticPlace.find_by(id: logistic_place_id)

          expedition_position.logistic_places.delete(logistic_place)
        end

        expedition_position.update!(quantity: expedition_position.quantity - params[:quantity])
      end
    rescue StandardError => e
      render json: { error: e.message }, status: :internal_server_error
    end

    # API calls for models fetch [GET] 
    def parts_by_user
      @parts = Part
        .joins(<<-SQL)
          LEFT JOIN client_order_positions ON client_order_positions.part_id = parts.id
          LEFT JOIN supplier_order_positions ON supplier_order_positions.part_id = parts.id
          LEFT JOIN clients ON parts.client_id = clients.id
          LEFT JOIN client_positions ON client_positions.part_id = parts.id
        SQL
        .where(user_id: @user.id)
        .select(
          'parts.*',
          'MAX(client_order_positions.price) AS latest_client_price',
          'MAX(supplier_order_positions.price) AS latest_supplier_price',
          'COUNT(CASE WHEN client_positions.sorted = false THEN 1 END) AS unsorted_positions_count', # Count unsorted positions
          'clients.name AS client_name' # Include the client's name
        )
        .group('parts.id, clients.name') # Group by parts.id and clients.name for aggregation
    
      render json: @parts.map { |part|
        part.attributes.merge(
          latest_client_price: part.attributes['latest_client_price'],
          latest_supplier_price: part.attributes['latest_supplier_price'],
          unsorted_positions_count: part.attributes['unsorted_positions_count'].to_i,
          client_name: part.attributes['client_name']
        )
      }
    end

    def fetch_unsorted_client_positions
      unsorted_positions = ClientPosition.includes(:part).where(part_id: params[:part_id], sorted: false)
    
      render json: unsorted_positions.map { |position|
        position.as_json.merge(
          reference_and_designation: "#{position.part.reference} #{position.part.designation}"
        )
      }, status: :ok
    rescue ActiveRecord::RecordNotFound => e
      render json: { error: e.message }, status: :not_found
    rescue StandardError => e
      render json: { error: e.message }, status: :internal_server_error
    end

    def fetch_user_client_orders
      client_orders = ClientOrder
                        .joins(client_order_positions: :part)
                        .joins(:client)
                        .where(clients: { user_id: @user.id })
                        .select(
                          'client_orders.id AS order_id',
                          'client_orders.number AS order_number',
                          'clients.name AS client_name',
                          'client_order_positions.quantity AS position_quantity',
                          'client_order_positions.delivery_date AS position_delivery_date',
                          'parts.reference AS part_reference',
                          'parts.designation AS part_designation',
                          'client_orders.order_delivery_time'
                        )
                        .order('client_order_positions.delivery_date ASC')
    
      # Format the results
      formatted_orders = client_orders.map do |order|
        {
          order_number: order.order_number,
          order_id: order.order_id,
          client_name: order.client_name,
          position_quantity: order.position_quantity,
          position_delivery_date: order.position_delivery_date,
          part_reference: order.part_reference,
          part_designation: order.part_designation,
        }
      end
    
      render json: formatted_orders, status: :ok
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'User not found' }, status: :not_found
    end

    def standard_stocks_positions_by_client
      standard_stocks = StandardStock.where(client_id: @client.id).includes(:client_positions)
  
      result = standard_stocks.map do |stock|
        {
          id: stock.id,
          address: stock.address,
          contact_name: stock.contact_name,
          current_quantity: stock.current_quantity,
          client_positions: stock.client_positions.where(part_id: @part_searched.id).map do |position|
            {
              quantity: position.quantity,
              reference_and_designation: "#{position.part.designation} #{position.part.reference}"
            }
          end
        }
      end
  
      render json: result, status: :ok
    rescue ActiveRecord::RecordNotFound => e
      render json: { error: e.message }, status: :not_found
    rescue StandardError => e
      render json: { error: e.message }, status: :internal_server_error
    end
  
    # Fetch Consignment Stocks and their Client Positions
    def consignment_stocks_positions_by_client
      consignment_stocks = ConsignmentStock.where(client_id: @client.id).includes(:client_positions)
  
      result = consignment_stocks.map do |stock|
        {
          id: stock.id,
          address: stock.address,
          contact_name: stock.contact_name,
          current_quantity: stock.current_quantity,
          client_positions: stock.client_positions.where(part_id: @part_searched.id).map do |position|
            {
              quantity: position.quantity,
              reference_and_designation: "#{position.part.designation} #{position.part.reference}"
            }
          end
        }
      end
  
      render json: result, status: :ok
    rescue ActiveRecord::RecordNotFound => e
      render json: { error: e.message }, status: :not_found
    rescue StandardError => e
      render json: { error: e.message }, status: :internal_server_error
    end

    def fetch_standard_stocks_by_client
      standard_stocks = StandardStock.where(client_id: params[:client_id])
                                     .includes(:client_positions)
    
      result = standard_stocks.map do |stock|
        {
          id: stock.id,
          address: stock.address,
          contact_name: stock.contact_name,
          client_positions: stock.client_positions.select(:id, :part_id, :quantity, :sorted)
        }
      end
    
      render json: result, status: :ok
    rescue ActiveRecord::RecordNotFound => e
      render json: { error: e.message }, status: :not_found
    rescue StandardError => e
      render json: { error: e.message }, status: :internal_server_error
    end
    
    def fetch_consignment_stocks_by_client
      consignment_stocks = ConsignmentStock.where(client_id: params[:client_id])
                                           .includes(:client_positions)
    
      result = consignment_stocks.map do |stock|
        {
          id: stock.id,
          address: stock.address,
          contact_name: stock.contact_name,
          client_positions: stock.client_positions.select(:id, :part_id, :quantity, :sorted)
        }
      end
    
      render json: result, status: :ok
    rescue ActiveRecord::RecordNotFound => e
      render json: { error: e.message }, status: :not_found
    rescue StandardError => e
      render json: { error: e.message }, status: :internal_server_error
    end

    def clients_by_part_ids
        part_ids = params[:part_ids]&.split(",") # Extract and split the part_ids from the query params
    
         # Fetch unique clients linked to the parts
        clients = Client.joins(:parts)
        .where(parts: { id: part_ids })
        .distinct
    
        render json: clients, status: :ok
      rescue => e
        render json: { error: e.message }, status: :unprocessable_entity
    end

    def fetch_supplier_orders_by_part
      @supplier_orders = SupplierOrder.joins(:parts, :supplier)
                        .where(parts: { id: @part_searched.id })
                        .includes(:client_orders)

      supplier_orders_with_client_numbers = @supplier_orders.map do |supplier_order|
      client_order_number = supplier_order.client_orders.first&.number

      supplier_order.as_json.merge(client_order_number: client_order_number)
      end

      render json: supplier_orders_with_client_numbers
    end

    def fetch_supplier_orders_by_user
      @supplier_orders = SupplierOrder
                          .joins(supplier: :user) # Join suppliers and users
                          .joins(:parts) # Join parts table
                          .where(suppliers: { user_id: params[:user_id] }) # Filter by user_id
                          .select(
                            'supplier_orders.*',
                            'parts.reference AS part_reference',
                            'parts.designation AS part_designation'
                          )

      render json: @supplier_orders.map do |order|
        order.attributes.merge(
          part_reference: order.attributes['part_reference'],
          part_designation: order.attributes['part_designation']
        )
      end
    end

    def fetch_uncompleted_supplier_orders_positions_by_user
      @supplier_orders_positions = SupplierOrderPosition
        .joins(supplier_order: { supplier: :user }) # Join suppliers and users
        .joins(:part) # Join parts table
        .where(suppliers: { user_id: params[:user_id] }) # Filter by user_id
        .where.not(status: 'completed') # Exclude completed supplier order positions
        .select(
          'supplier_order_positions.*',
          'supplier_orders.number AS supplier_order_number',
          'supplier_orders.status AS supplier_order_status',
          'parts.reference AS part_reference',
          'parts.designation AS part_designation'
        )
    
      render json: @supplier_orders_positions.map do |position|
        position.attributes.merge(
          supplier_order_number: position.attributes['supplier_order_number'],
          supplier_order_status: position.attributes['supplier_order_status'],
          part_reference: position.attributes['part_reference'],
          part_designation: position.attributes['part_designation']
        )
      end
    rescue ActiveRecord::RecordNotFound => e
      render json: { error: e.message }, status: :not_found
    rescue StandardError => e
      render json: { error: e.message }, status: :internal_server_error
    end

    def fetch_supplier_orders_positions_by_user_and_part
      @supplier_orders_positions = SupplierOrderPosition
                       .joins(supplier_order: { supplier: :user }) # Join suppliers and users
                       .joins(:part) # Join parts table
                       .where(suppliers: { user_id: params[:user_id] }) # Filter by user_id
                       .where(parts: { id: params[:part_id] })
                       .select(
                         'supplier_order_positions.*',
                         'supplier_orders.number AS supplier_order_number',
                         'supplier_orders.status AS supplier_order_status',
                         'parts.reference AS part_reference',
                         'parts.designation AS part_designation'
                       )

      render json: @supplier_orders_positions.map do |position|
        position.attributes.merge(
          supplier_order_number: position.attributes['supplier_order_number'],
          supplier_order_status: position.attributes['supplier_order_status'],
          part_reference: position.attributes['part_reference'],
          part_designation: position.attributes['part_designation']
        )
      end
    end
  
    def fetch_client_orders_by_part
      client_order_positions = ClientOrderPosition
        .joins(client_order: :client) # Join client through client_order
        .joins(:part)                # Join the part table
        .where(part_id: params[:part_id], status: 'undelivered') # Use params[:part_id] for the filter
        .select(
          'client_order_positions.*',
          'client_orders.number AS client_order_number',
          'clients.name AS client_name'
        )
    
      # Render the data with client_order and client details
      render json: client_order_positions.map { |position|
        position.attributes.merge(
          client_order_number: position.attributes['client_order_number'],
          client_name: position.attributes['client_name']
        )
      }
    end

    #INDEX
    def fetch_expedition_orders
      supplier_order_indices = @expedition.supplier_order_indices.includes(:part)

      indices = supplier_order_indices.map do |index|
        part = Part.find_by(id: index.part_id)
        {
          id: index.id,
          quantity: index.quantity,
          part_id: part&.id,
          part_designation: part&.designation,
          part_reference: part&.reference
        }
      end

      render json: indices
    rescue ActiveRecord::RecordNotFound => e
      render json: { error: e.message }, status: :not_found
    end

    def expeditions
      expeditions = Expedition
      .joins(:supplier) # Join suppliers table
      .where(suppliers: { user_id: params[:user_id] }) # Filter by user's suppliers

      render json: expeditions
    end

    def fetch_undelivered_expeditions
      expeditions = Expedition
      .where(status: 'undelivered')
      .joins(:supplier) # Join suppliers table
      .where(suppliers: { user_id: params[:user_id] }) # Filter by user's suppliers
      .select('expeditions.*, suppliers.name AS supplier_name') # Include supplier_name in the query

      result = expeditions.map do |expedition|
        expedition.attributes.merge('supplier_name' => expedition.supplier_name)
      end
    
      render json: result, status: :ok
    end

    def fetch_delivered_expeditions
      expeditions = Expedition
      .where(status: 'delivered')
      .joins(:supplier) # Join suppliers table
      .where(suppliers: { user_id: params[:user_id] }) # Filter by user's suppliers
      .select('expeditions.*, suppliers.name AS supplier_name') # Include supplier_name in the query

      result = expeditions.map do |expedition|
        expedition.attributes.merge('supplier_name' => expedition.supplier_name)
      end
    
      render json: result, status: :ok
    end
  
    #FILTERED BY PART
    def fetch_expeditions_supplier_order_indices_by_part
      @supplier_order_indices = SupplierOrderIndex
                                  .joins(supplier_order_position: { supplier_order: :supplier })
                                  .joins(:expeditions)
                                  .where(part_id: @part_searched.id)
                                  .select(
                                    'supplier_order_indices.*',
                                    'supplier_order_positions.delivery_date AS delivery_date',
                                    'supplier_orders.number AS supplier_order_number',
                                    'suppliers.name AS supplier_name',
                                    'expeditions.real_departure_time AS real_departure_time',
                                    'expeditions.transporter AS transporter',
                                  )
    
      render json: @supplier_order_indices.map do |index|
        index.attributes.merge(
          delivery_date: index.attributes['delivery_date'],
          supplier_order: {
            number: index.attributes['supplier_order_number'],
            name: index.attributes['supplier_name']
          },
          real_departure_time: index.attributes['real_departure_time'],
          expedition_transporter: index.attributes['transporter']
        )
      end
    end

    def fetch_expedition_position_parts_by_sub_contractor
      part_id = params[:part_id]
    
      # Fetch expedition positions associated with the given part and related subcontractors
      expedition_positions = ExpeditionPosition.joins(:sub_contractors, :expedition)
                                               .where(part_id: part_id)
                                               .select('expedition_positions.*, expeditions.number AS expedition_number')
    
      # Build a response containing expedition positions and their associated subcontractors
      result = expedition_positions.map do |position|
        position.sub_contractors.map do |subcontractor|
          {
            expedition_position_id: position.id,
            part_id: position.part_id,
            expedition_number: position.expedition_number,
            quantity: position.quantity,
            subcontractor_name: subcontractor.name,
            subcontractor_id: subcontractor.id
          }
        end
      end.flatten
    
      render json: result, status: :ok
    end

    def fetch_expedition_position_parts_by_logistic_place
      part_id = params[:part_id]
    
      # Fetch expedition positions associated with the given part and related subcontractors
      expedition_positions = ExpeditionPosition.joins(:logistic_places, :expedition)
                                               .where(part_id: part_id)
                                               .select('expedition_positions.*, expeditions.number AS expedition_number')
    
      # Build a response containing expedition positions and their associated subcontractors
      result = expedition_positions.map do |position|
        position.logistic_places.map do |lp|
        {
          expedition_position_id: position.id,
          expedition_id: position.expedition_id,
          expedition_number: position.expedition_number,
          quantity: position.quantity,
          part_id: position.part_id,
          logistic_place_name: lp.name,
          logistic_place_id: lp.id
        }
        end
      end.flatten
    
      render json: result, status: :ok
    end

    def fetch_sub_contractors_by_part
      @sub_contractors = SubContractor.joins(:parts)
                   .where(parts: { id: @part_searched.id })

      render json: @sub_contractors
    end
  
    def fetch_logistic_places_by_part
      @logistic_places = LogisticPlace.joins(:parts)
                   .where(parts: { id: @part_searched.id })

      render json: @logistic_places
    end

    def part_related_data
      @part_searched = Part.includes(:supplier_orders, :client_orders, :sub_contractors, :logistic_places)
                          .find_by(id: params[:part_id])
    
      if @part_searched
        suppliers = @part_searched.supplier_orders.map(&:supplier).uniq
        client = @part_searched.client
        sub_contractors = @part_searched.sub_contractors.uniq
    
        # Fetch the latest supplier order position price for the part
        last_supplier_order_position = SupplierOrderPosition
                                        .joins(:supplier_order)
                                        .where(part_id: @part_searched.id)
                                        .order('supplier_order_positions.created_at DESC')
                                        .first
        last_supplier_price = last_supplier_order_position&.price
    
        # Fetch the latest client order position price for the part
        last_client_order_position = ClientOrderPosition
                                      .joins(:client_order)
                                      .where(part_id: @part_searched.id)
                                      .order('client_order_positions.created_at DESC')
                                      .first
        last_client_price = last_client_order_position&.price
    
        render json: @part_searched.as_json.merge(
          suppliers: suppliers, 
          client: client, 
          sub_contractors: sub_contractors, 
          supplier_price: last_supplier_price, 
          client_price: last_client_price
        )
      else
        render json: { error: "Part not found" }, status: :not_found
      end
    end

    def client_index
      @clients = Client.where(user_id: params[:user_id])
      render json: @clients
    end

    def supplier_index
      @suppliers = Supplier.where(user_id: params[:user_id])
      render json: @suppliers
    end

    def subcontractors_index
      @subcontractors = SubContractor.where(user_id: params[:user_id])
      render json: @subcontractors
    end

    def logistic_places_index
      @logistic_places = LogisticPlace.where(user_id: params[:user_id])
      render json: @logistic_places
    end
  
    # Call all parts from a supplier
    def parts_by_supplier
      @parts = @supplier.parts
      render json: @parts
    end
  
    # Call all parts from a client
    def parts_by_client
      @parts = Part.joins(:client_orders).where(client_orders: { client_id: @client.id }).distinct
      render json: @parts
    end
  
    # Call all parts from many supplier_orders
    def parts_by_supplier_orders
      @parts = Part.joins(:supplier_orders)
              .where(supplier_orders: { id: @supplier_orders.pluck(:id) })
              .distinct
      render json: @parts
    end
  
    # Call all parts from many client_orders
    def parts_by_client_orders
      @parts = Part.joins(:client_orders).where(client_orders: { id: @client_orders.pluck(:id) }).distinct
      render json: @parts
    end

    # API calls for models deletion [DELETE]
    def delete_client_order
      @client_order = ClientOrderPosition.find_by(id: params[:client_order_id])
    
      if @client_order
        @client_order.destroy
      
        render json: { success: "Client order #{client_order.number} deleted successfully" }, status: :ok
      else
        render json: { error: "Client order not found" }, status: :not_found
      end
    end

    def delete_part
      @part = Part.find_by(id: params[:id])
    
      if @part
        @part.destroy
      
        render json: { success: "Part deleted successfully" }, status: :ok
      else
        render json: { error: "Client order not found" }, status: :not_found
      end
    end

    def delete_supplier_order
      @supplier_order = SupplierOrderPosition.find_by(id: params[:supplier_order_id])
    
      if @supplier_order
        @supplier_order.destroy
        render json: { success: "Supplier order #{supplier_order.number} deleted successfully" }, status: :ok
      else
        render json: { error: "Supplier order not found" }, status: :not_found
      end
    end
  
    private

    def client_params
      params.require(:client).permit(
        :name, :address, :contact_email, :contact_name,
        consignment_stocks: [:address, :contact_name, :contact_email],
        standard_stocks: [:address, :contact_name, :contact_email]
      )
    end

    def supplier_params
      params.require(:supplier).permit(:name, :address, :contact_email, :contact_name, :knowledge)
    end

    def part_params 
      params.require(:part).permit(:reference, :weight, :designation, :material, :drawing, :client_id, :supplier_id)
    end

    def client_order_params
      params.require(:client_order).permit(:number, :price, :client_contact, :order_date, :order_delivery_time, :client_id, :quantity, :transporter, :user_id, :part_id,
        client_order_positions: [:part_id, :price, :quantity, :delivery_date]
      )
    end

    def subcontractor_params
      params.require(:subcontractor).permit(:name, :address, :knowledge, :contact_email, :contact_name)
    end

    def logistic_place_params
      params.require(:logistic_place).permit(:name, :address, :knowledge, :contact_email, :contact_name)
    end

    def supplier_order_params
      params.require(:supplier_order).permit(:number, :price, :quantity_status, :supplier_contact, :order_date, :order_delivery_time, :estimated_delivery_time, :estimated_departure_time, :supplier_id, :quantity, :transporter, :user_id, :part_id, 
        supplier_order_positions_attributes: [
          :part_id,
          :price,
          :quantity,
          :delivery_date,
          :original_quantity
        ] )
    end

    def expedition_params
      params.require(:expedition).permit(:real_departure_time, :price, :number, :estimated_departure_time, :arrival_time, :transporter)
    end

    def set_part
      @part_searched = Part.includes(:supplier_orders, :client_orders, :sub_contractors, :logistic_places, :supplier_order_indices, :supplier_order_positions)
      .find_by(id: params[:part_id])
    end

    def set_expedition
      @expedition = Expedition.find_by(id: params[:expedition_id])
    end
  
    def set_user
      @user = User.find(params[:user_id])
    end

    def set_user_by_id
      @user = User.find_by(id: params[:user_id])
    end
  
    def set_supplier
      @supplier = Supplier.find(params[:supplier_id])
    end
  
    # Set the client
    def set_client
      @client = Client.find_by(id: params[:client_id])
    end
  
    # Set the supplier orders (accepts an array of supplier_order_ids)
    def set_supplier_orders
      @supplier_orders = SupplierOrder.where(id: params[:supplier_order_ids])
    end
  
    # Set the client orders (accepts an array of client_order_ids)
    def set_client_orders
      @client_orders = ClientOrder.where(id: params[:client_order_ids])
    end
  end
  