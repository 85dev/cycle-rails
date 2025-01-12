class PartsController < ApplicationController
    before_action :set_user_by_id, only: [:create_company, :companies_index]
    before_action :set_supplier, only: [:fetch_parts_by_supplier]
    before_action :set_client, only: [:fetch_contacts_by_client, :create_part, :fetch_parts_by_client_and_consignment_stock, :fetch_parts_by_client, :standard_stocks_positions_by_client, :consignment_stocks_positions_by_client, :fetch_standard_stocks_by_client, :fetch_consignment_stocks_by_client]
    before_action :set_supplier_orders, only: [:parts_by_supplier_orders]
    before_action :set_client_orders, only: [:parts_by_client_orders]
    before_action :set_part, only: [ :consignment_stocks_positions_by_client, :fetch_client_orders_by_part, :standard_stocks_positions_by_client, :consignment_stocks_positions_by_client, :fetch_unsorted_client_positions, :fetch_expeditions_supplier_order_indices_by_part, :fetch_logistic_places_by_part, :fetch_sub_contractors_by_part, :fetch_supplier_orders_by_part]
    before_action :set_expedition, only: [:fetch_expedition_orders, :dispatch_expedition]
    before_action :set_company, only: [
      :fetch_company_addresses_and_client_adresses_by_name,
      :fetch_contacts_by_client,
      :fetch_client_orders_by_company,
      :fetch_supplier_orders_by_company,
      :create_transporter,
      :transporters_index_by_company,
      :fetch_uncompleted_supplier_orders_positions_by_company,
      :fetch_supplier_orders_positions_by_company_and_part,
      :create_supplier, 
      :fetch_delivered_expeditions,
      :subcontractors_index, 
      :logistic_places_index, 
      :expeditions_by_company, 
      :fetch_undelivered_expeditions,
      :parts_by_company, 
      :fetch_supplier_orders_by_company, 
      :create_part, 
      :client_index, 
      :fetch_client_orders_by_part, 
      :fetch_expeditions_supplier_order_indices_by_part, 
      :fetch_logistic_places_by_part, 
      :fetch_sub_contractors_by_part, 
      :fetch_supplier_orders_by_part,
      :create_consignment_consumption, 
      :fetch_kpi_metrics, 
      :fetch_future_company_client_orders, 
      :create_sub_contractor, 
      :create_logistic_place, 
      :create_client
    ]
    # API calls for models creation [POST]
    # Create PART linked to CLIENT, SUPPLIER and COMPANY
    def create_part
      suppliers = Supplier.where(id: params[:supplier_ids])

      @part = @company.parts.new(part_params)
      @part.client = @client

      ActiveRecord::Base.transaction do
        if @part.save
          @part.suppliers << suppliers

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

    def create_transporter
      transporter = @company.transporters.new(transporter_params)
  
      if transporter.save
        render json: { message: 'Transporter created successfully', transporter: transporter }, status: :created
      else
        render json: { errors: transporter.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # Create CLIENT linked to COMPANY along with its stocks
    def create_client
      ActiveRecord::Base.transaction do
        @client = @company.clients.new(client_params)

        if @client.save
          # Process contacts
          if params[:client][:contacts]
            params[:client][:contacts].each do |contact_params|
              @client.contacts.create!(
                email: contact_params[:email],
                first_name: contact_params[:first_name],
                last_name: contact_params[:last_name],
                role: contact_params[:role]
              )            
            end
          end

          # Process consignment stocks
          if params[:client][:consignment_stocks]
            params[:client][:consignment_stocks].each do |stock_params|
              raise ActiveRecord::RecordInvalid.new(@client) if stock_params[:address].blank?

              @client.consignment_stocks.create!(
                address: stock_params[:address]
              )
            end
          end

          # Process standard stocks
          if params[:client][:standard_stocks]
            params[:client][:standard_stocks].each do |stock_params|
              raise ActiveRecord::RecordInvalid.new(@client) if stock_params[:address].blank?

              @client.standard_stocks.create!(
                address: stock_params[:address]
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

    # Create SUBCONTRACTOR linked to COMPANY
    def create_sub_contractor
      merged_params = subcontractor_params.merge(company: @company)

      @subcontractor = SubContractor.new(merged_params)

      if @subcontractor.save
        if params[:subcontractor][:contacts]
          params[:subcontractor][:contacts].each do |contact_params|
            @subcontractor.contacts.create!(
              email: contact_params[:email],
              first_name: contact_params[:first_name],
              last_name: contact_params[:last_name],
              role: contact_params[:role]
            )            
          end
        end
        render json: { success: 'Subcontractor created successfully', subcontractor: @subcontractor }, status: :created
      else
        render json: { errors: @subcontractor.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # Create SUBCONTRACTOR linked to COMPANY
    def create_logistic_place
      merged_params = logistic_place_params.merge(company: @company)

      @logistic_place = LogisticPlace.new(merged_params)

      if @logistic_place.save
        render json: { success: 'logistic_place created successfully', logistic_place: @logistic_place }, status: :created
      else
        render json: { errors: @logistic_place.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # Create CLIENT linked to COMPANY
    def create_supplier
      @supplier = @company.suppliers.new(supplier_params)

      if @supplier.save
        if params[:supplier][:contacts]
          params[:supplier][:contacts].each do |contact_params|
            @supplier.contacts.create!(
              email: contact_params[:email],
              first_name: contact_params[:first_name],
              last_name: contact_params[:last_name],
              role: contact_params[:role]
            )            
          end
        end
        render json: { success: 'supplier created successfully', supplier: @supplier }, status: :created
      else
        render json: { errors: @supplier.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def create_company
      ActiveRecord::Base.transaction do
        # Create the company with provided parameters
        @company = Company.new(company_params)
        
        if @company.save
          # Automatically associate the user with the company as an owner
          Account.create!(
            user_id: @user.id, # Assuming you have a current_user helper from authentication
            company_id: @company.id,
            is_owner: true,
            status: 'accepted'
          )
          
          render json: { success: 'Company created successfully', company: @company }, status: :created
        else
          render json: { errors: @company.errors.full_messages }, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: e.message }, status: :unprocessable_entity
      end
    end

    def create_consignment_consumption
      @stock = ConsignmentStock.find(params[:consignment_stock_id])
      
      ActiveRecord::Base.transaction do
        # Create the main consumption record
        @consumption = ConsignmentConsumption.create!(
          consignment_stock: @stock,
          begin_date: params[:begin_date],
          end_date: params[:end_date],
          number: params[:number]
        )

        # Create consumption positions
        params[:consignment_consumptions].each do |consumption|
          part_id = consumption[:part_id]
          quantity = consumption[:quantity].to_i

          next if quantity <= 0 
    
          consignment_stock_part = @stock.consignment_stock_parts.find_by(part_id: part_id)

          if consignment_stock_part.current_quantity < quantity
            raise StandardError, "Insufficient stock for part_id: #{part_id}. Available: #{consignment_stock_part.current_quantity}, Requested: #{quantity}"
          end

          consignment_stock_part.update!(current_quantity: consignment_stock_part.current_quantity - quantity)
    
          ConsignmentConsumptionPosition.create!(
            consignment_consumption: @consumption,
            part_id: consumption[:part_id],
            quantity: consumption[:quantity],
            price: consumption[:price]
          )
        end

        render json: @consumption, status: :created
      rescue ActiveRecord::RecordInvalid => e
        render json: { error: e.message }, status: :unprocessable_entity
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

          contact = Contact.find_by(id: params[:contact_id])

          if contact
            @client_order.contact = contact
            @client_order.save!
          end

          render json: { success: "Client order created successfully", client_order: @client_order }, status: :created
        else
          render json: { errors: @client_order.errors.full_messages }, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: e.message }, status: :unprocessable_entity
      end
    end

    def complete_client_order
      @client_order = ClientOrder.find_by(id: params[:client_order_id])

      if @client_order
        ActiveRecord::Base.transaction do
          # Update the client order status
          delivery_date = params[:delivery_date] || Date.today
          @client_order.update!(order_status: 'delivered', delivery_date: delivery_date)
          
          # Update all associated positions to delivered and set their delivery date
          @client_order.client_order_positions.update_all(status: 'delivered', delivery_date: delivery_date)
    
          render json: { success: "Client order #{@client_order.number} marked as delivered" }, status: :ok
        end
      else
        render json: { error: "Client order not found" }, status: :not_found
      end
    rescue ActiveRecord::RecordInvalid => e
      render json: { errors: e.message }, status: :unprocessable_entity
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

              contact = Contact.find_by(id: params[:contact_id])

              if contact
                supplier_order.contact = contact
                supplier_order.save!
              end

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
      transporter = Transporter.find_by(id: params[:transporter_id])
      @expedition.supplier = supplier
      @expedition.transporter = transporter

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
              part: supplier_order_position.part,
              expedition: @expedition
            )

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
        # Update expedition status to delivered
        expedition = Expedition.find_by(id: params[:expedition_id])
        raise ActiveRecord::RecordNotFound, "Expedition not found" unless expedition

        supplier_order_indices_ids.each_with_index do |supplier_order_index_id, index|
          supplier_order_index = SupplierOrderIndex.find_by(id: supplier_order_index_id)
          raise ActiveRecord::RecordNotFound, "SupplierOrderIndex not found" unless supplier_order_index
    
          subcontractor_name = subcontractors[index].presence
          logistic_place_name = logistic_places[index].presence
          part_reference = references[index]
          part_designation = designations[index]
          client_name = clients[index].presence
          is_clone = clones[index]
    
          part = Part.find_by(reference: part_reference, designation: part_designation)
          raise ActiveRecord::RecordNotFound, "Part not found" unless part
    
          # Update index status
          supplier_order_index.update!(status: 'delivered')
    
          if client_name
            # Handle dispatch to client
            client = Client.find_by(name: client_name)
            raise ActiveRecord::RecordNotFound, "Client not found" unless client
    
            create_client_position(
              client_id: client.id,
              supplier_order_index_id: supplier_order_index_id,
              expedition_id: expedition.id,
              part_id: part.id,
              quantity: supplier_order_index.quantity,
              is_clone: is_clone,
              sorted: false
            )
          else
            # Handle subcontractor and logistic place dispatch
            # Prepare parameters for creating the expedition position
            position_params = {
              expedition_id: expedition.id,
              supplier_order_index_id: supplier_order_index.id,
              part_id: part.id,
              quantity: supplier_order_index.quantity,
              is_clone: is_clone,
              finition_status: supplier_order_index.finition_status
            }

            # If subcontractor or logistic place is specified, use the proper destination type
            if subcontractor_name
              subcontractor = SubContractor.find_by(name: subcontractor_name)
              raise ActiveRecord::RecordNotFound, "Subcontractor not found" unless subcontractor

              position_params[:destination_type] = "subcontractor"
              position_params[:subcontractor_id] = subcontractor.id
            elsif logistic_place_name
              logistic_place = LogisticPlace.find_by(name: logistic_place_name)
              raise ActiveRecord::RecordNotFound, "Logistic place not found" unless logistic_place

              position_params[:destination_type] = "logistic_place"
              position_params[:logistic_place_id] = logistic_place.id
            end

            # Create the expedition position using the extracted parameters
            position = create_expedition_position(**position_params)
    
            if subcontractor_name
              subcontractor = SubContractor.find_by(name: subcontractor_name)
              raise ActiveRecord::RecordNotFound, "Subcontractor not found" unless subcontractor
    
              position.sub_contractors << subcontractor
              create_expedition_position_history(
                expedition_position_id: position.id,
                part_id: part.id,
                event_type: 'subcontractor',
                location_name: subcontractor_name
              )
            end
    
            if logistic_place_name
              logistic_place = LogisticPlace.find_by(name: logistic_place_name)
              raise ActiveRecord::RecordNotFound, "Logistic place not found" unless logistic_place
    
              position.logistic_places << logistic_place
              create_expedition_position_history(
                expedition_position_id: position.id,
                part_id: part.id,
                event_type: 'logistic_place',
                location_name: logistic_place_name
              )
            end
          end
        end
    
        expedition.update!(status: 'delivered', arrival_time: params[:arrival_time])
    
        render json: { success: "Expedition dispatch completed successfully" }, status: :ok
      end
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound => e
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

            client_position.standard_stocks << standard_stock
            client_position.update!(sorted: true, consignment_stock: false)
          elsif consignment_stocks[index] != 0
            consignment_stock = ConsignmentStock.find_by(id: consignment_stocks[index])
            
            consignment_stock_part = ConsignmentStockPart.find_or_initialize_by(
              consignment_stock_id: consignment_stock.id,
              part_id: client_position.part_id
            )

            consignment_stock_part.current_quantity ||= 0
            consignment_stock_part.current_quantity += client_position.quantity
            consignment_stock_part.save!

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
      transfer_quantity = params[:quantity].to_i
      destination_type = params[:destination_type]
      destination_name = params[:destination_name]
      delivery_slip = params[:delivery_slip]
      transfer_date = params[:transfer_date] || Date.today
      
      return render json: { error: "Expedition position not found" }, status: :not_found unless expedition_position
    
      # Default value for is_clone if it's not provided
      is_clone = params[:is_clone].present? ? params[:is_clone] : false

      logistic_place_id = params[:logistic_place_id]
      subcontractor_id = params[:subcontractor_id]
    
      ActiveRecord::Base.transaction do
        total_quantity = expedition_position.quantity
    
        if transfer_quantity == total_quantity
          expedition_position.sub_contractors.clear
          expedition_position.logistic_places.clear
    
          case destination_type
          when "subcontractor"
            subcontractor = SubContractor.find_by(id: params[:subcontractor_id])
            return render json: { error: "Subcontractor not found" }, status: :not_found unless subcontractor
    
            expedition_position.sub_contractors << subcontractor
    
          when "logistic_place"
            logistic_place = LogisticPlace.find_by(id: params[:logistic_place_id])
            return render json: { error: "Logistic place not found" }, status: :not_found unless logistic_place
    
            expedition_position.logistic_places << logistic_place
    
          when "client"
            client = Client.find_by(name: destination_name)
            return render json: { error: "Client not found" }, status: :not_found unless client
    
            # Pass arguments as a hash for `create_client_position`
            create_client_position(
              client_id: client.id,
              part_id: params[:part_id],
              expedition_id: expedition_position.expedition_id,
              supplier_order_index_id: expedition_position.supplier_order_index_id,
              quantity: transfer_quantity,
              is_clone: is_clone,
              sorted: false
            )
          else
            return render json: { error: "Invalid destination type" }, status: :unprocessable_entity
          end
    
          create_expedition_position_history(
            expedition_position_id: expedition_position.id,
            part_id: params[:part_id],
            transfer_date: transfer_date,
            delivery_slip: delivery_slip,
            event_type: destination_type,
            location_name: destination_name
          )
    
        elsif transfer_quantity < total_quantity
          remaining_quantity = total_quantity - transfer_quantity
          expedition_position.update!(quantity: remaining_quantity)
    
          if destination_type == "client"
            client = Client.find_by(name: destination_name)
            return render json: { error: "Client not found" }, status: :not_found unless client
    
            create_client_position(
              client_id: client.id,
              part_id: params[:part_id],
              expedition_id: expedition_position.expedition_id,
              supplier_order_index_id: expedition_position.supplier_order_index_id,
              quantity: transfer_quantity,
              is_clone: is_clone,
              sorted: false
            )
          else
            create_expedition_position(
              expedition_id: expedition_position.expedition_id,
              supplier_order_index_id: expedition_position.supplier_order_index_id,
              part_id: params[:part_id],
              quantity: transfer_quantity,
              is_clone: is_clone,
              finition_status: expedition_position.finition_status,
              destination_type: destination_type,
              logistic_place_id: logistic_place_id,
              subcontractor_id: subcontractor_id
            )
          end
    
          create_expedition_position_history(
            expedition_position_id: expedition_position.id,
            transfer_date: transfer_date,
            delivery_slip: delivery_slip,
            part_id: params[:part_id],
            event_type: destination_type,
            location_name: destination_name
          )
        else
          render json: { error: "Transfer quantity exceeds available quantity" }, status: :unprocessable_entity
          return
        end
      end
    
      render json: { success: "Position transferred successfully" }, status: :ok
    rescue StandardError => e
      render json: { error: e.message }, status: :internal_server_error
    end

    # API calls for models fetch [GET] 
    def parts_by_company
      @parts = Part
        .joins(<<-SQL)
          LEFT JOIN client_order_positions ON client_order_positions.part_id = parts.id
          LEFT JOIN supplier_order_positions ON supplier_order_positions.part_id = parts.id
          LEFT JOIN clients ON parts.client_id = clients.id
          LEFT JOIN client_positions ON client_positions.part_id = parts.id
        SQL
        .where(company_id: @company.id)
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

    def fetch_future_company_client_orders
      client_orders = ClientOrder
                        .joins(client_order_positions: :part)
                        .joins(:client)
                        .where(clients: { company_id: @company.id })
                        .where(order_status: 'undelivered')                         
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
      render json: { error: 'Company not found' }, status: :not_found
    end

    def standard_stocks_positions_by_client
      standard_stocks = StandardStock.where(client_id: @client.id).includes(:client_positions)
  
      result = standard_stocks.map do |stock|
        {
          id: stock.id,
          address: stock.address,
          contact_name: stock.contact_name,
          client_positions: stock.client_positions.where(part_id: @part_searched.id).map do |position|
            {
              id: position.id,
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
  
    def consignment_stocks_positions_by_client
      consignment_stocks = ConsignmentStock.where(client_id: @client.id).includes(:client_positions)
  
      result = consignment_stocks.map do |stock|
        stock_part = stock.consignment_stock_parts.find_by(part_id: @part_searched.id)

          consumption_positions = ConsignmentConsumptionPosition
          .joins(:consignment_consumption, :part)
          .where(
            consignment_consumptions: { consignment_stock_id: stock.id },
            part_id: @part_searched.id
          )
          .select(:id, :quantity, :price, :created_at,
                 'parts.reference AS part_reference',
            'parts.designation AS part_designation',
            'consignment_consumptions.begin_date AS begin_date',
            'consignment_consumptions.end_date AS end_date')

        {
          id: stock.id,
          address: stock.address,
          contact_name: stock.contact_name,
          current_quantity: stock_part&.current_quantity || 0,
          consumption_positions: consumption_positions.map do |consumption|
            {
              id: consumption.id,
              quantity: consumption.quantity,
              price: consumption.price,
              consumption_period: "#{consumption.begin_date&.strftime('%d %b %Y')} - #{consumption.end_date&.strftime('%d %b %Y')}",
              reference_and_designation: "#{consumption.part_designation} #{consumption.part_reference}"
            }
          end,
          client_positions: stock.client_positions.where(part_id: @part_searched.id).map do |position|
            {
              id: position.id,
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

    def fetch_kpi_metrics
      # Get all client orders for the company
      client_order_positions = ClientOrderPosition
        .joins(client_order: { client: :company })
        .where(clients: { company_id: params[:company_id] })
        .where('client_order_positions.delivery_date >= ? AND client_order_positions.delivery_date <= ?', Date.today, Date.today + 30.days)
    
      undelivered_expeditions = Expedition.where(status: 'undelivered').count
    
      total_active_orders = client_order_positions.where(status: 'undelivered').count
    
      render json: {
        totalActiveOrders: total_active_orders,
        runningExpeditions: undelivered_expeditions
      }
    end

    def fetch_position_history
      client_position = ClientPosition.includes(:supplier_order_index).find_by(id: params[:client_position_id])
    
      # Retrieve related records
      supplier_order_index = client_position.supplier_order_index
      expedition = supplier_order_index&.expedition
      supplier_order = supplier_order_index&.supplier_order_position&.supplier_order
      client_order = ClientOrder.joins(:client_order_positions).find_by(client_order_positions: { part_id: client_position.part_id })
    
      # Retrieve expedition position histories
      expedition_position_histories = ExpeditionPositionHistory
        .joins(expedition_position: { expedition: :supplier_order_indices })
        .where(supplier_order_indices: { id: client_position.supplier_order_index_id })
        .order(created_at: :asc)
        .map do |history|
          duration = history.updated_at ? 
            ((history.updated_at - history.created_at) / 1.day).round(2) : 
            'Ongoing'
    
          {
            event_type: history.event_type,
            location_name: history.location_name,
            start_time: history.created_at,
            end_time: history.updated_at,
            duration_days: duration
          }
        end
    
      # Format the history data
      formatted_history = {
        client_position: {
          id: client_position.id,
          quantity: client_position.quantity,
          location: client_position.location,
          sorted: client_position.sorted,
          created_at: client_position.created_at,
          updated_at: client_position.updated_at,
          client_id: client_position.client_id,
          client_name: client_position.client&.name
        },
        supplier_order_index: supplier_order_index&.slice(:id, :quantity, :status, :created_at, :updated_at),
        expedition: expedition&.slice(:id, :number, :status, :real_departure_time, :arrival_time),
        supplier_order: supplier_order&.slice(:id, :number, :quantity, :status, :created_at, :arrival_address, :order_delivery_time)&.merge(
          supplier_name: supplier_order&.supplier&.name
        ),
        client_order: client_order&.slice(:id, :number, :quantity, :order_date),
        expedition_position_histories: expedition_position_histories,
        counts: (expedition_position_histories&.length || 0) +
                (supplier_order_index ? 1 : 0) +
                (expedition ? 1 : 0) +
                (supplier_order ? 1 : 0) +
                (client_order ? 1 : 0)
      }
    
      # Flatten the global object
      flattened_history = flatten_object(formatted_history)
    
      render json: flattened_history, status: :ok
    rescue ActiveRecord::RecordNotFound => e
      render json: { error: e.message }, status: :not_found
    end
    
    # Recursive method to flatten nested arrays or hashes
    def flatten_object(object)
      case object
      when Hash
        object.transform_values { |value| flatten_object(value) }
      when Array
        object.flat_map { |value| flatten_object(value) }
      else
        object
      end
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
                                           .includes(:client_positions, :consignment_stock_parts)
    
      result = consignment_stocks.map do |stock|
        {
          id: stock.id,
          address: stock.address,
          contact_name: stock.contact_name,
          client_positions: stock.client_positions.select(
            :id, 
            :part_id, 
            :quantity, 
            :sorted
          )
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

    def fetch_supplier_orders_by_company
      @supplier_orders = SupplierOrder
                          .joins(supplier: :company) # Join suppliers and companys
                          .joins(:parts) # Join parts table
                          .where(suppliers: { company_id: params[:company_id] }) # Filter by company_id
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

    def fetch_uncompleted_supplier_orders_positions_by_company
      @supplier_orders_positions = SupplierOrderPosition
        .joins(supplier_order: { supplier: :company }) # Join suppliers and companys
        .joins(:part) # Join parts table
        .where(suppliers: { company_id: params[:company_id] }) # Filter by company_id
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

    def fetch_supplier_orders_positions_by_company_and_part
      @supplier_orders_positions = SupplierOrderPosition
                       .joins(supplier_order: { supplier: :company }) # Join suppliers and companys
                       .joins(:part) # Join parts table
                       .where(suppliers: { company_id: params[:company_id] }) # Filter by company_id
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

    def expeditions_by_company
      expeditions = Expedition
      .joins(:supplier) # Join suppliers table
      .where(suppliers: { company_id: params[:company_id] }) # Filter by company's suppliers

      render json: expeditions
    end

    def transporters_index_by_company
      transporters = Transporter.where(company_id: @company.id) # Filter by company_id

      render json: transporters, status: :ok
    end

    def fetch_company_addresses_and_client_adresses_by_name
      client = Client.find_by(name: params[:client_name])

      if client
        logistic_places = @company.logistic_places.select(:id, :address).map do |lp|
          { id: lp.id, address: lp.address, source: 'logistic' }
        end
    
        sub_contractors = @company.sub_contractors.select(:id, :address).map do |sc|
          { id: sc.id, address: sc.address, source: 'subcontractor' }
        end

        consignment_addresses = client.consignment_stocks.select(:id, :address).map do |stock|
          { id: stock.id, address: stock.address, type: "consignment" }
        end

        standard_addresses = client.standard_stocks.select(:id, :address).map do |stock|
          { id: stock.id, address: stock.address, type: "standard" }
        end
    
        addresses = logistic_places + sub_contractors + consignment_addresses + standard_addresses
    
        render json: {
          client: client,
          addresses: addresses
        }, status: :ok
      else
        render json: { error: "Client not found" }, status: :not_found
      end
    end

    def fetch_undelivered_expeditions
      expeditions = Expedition
        .joins(:supplier)
        .left_joins(:supplier_order_indices) # Use supplier_order_indices for the count
        .where(status: 'undelivered')
        .where(suppliers: { company_id: params[:company_id] })
        .select(
          'expeditions.*', 
          'suppliers.name AS supplier_name', 
          'COUNT(supplier_order_indices.id) AS positions_count' # Count supplier_order_indices
        )
        .group('expeditions.id, suppliers.name') # Group by expeditions and supplier name

      result = expeditions.map do |expedition|
        positions = ExpeditionPosition.where(expedition_id: expedition.id)

        expedition.attributes.merge(
          supplier_name: expedition.supplier_name,
          positions_count: expedition.attributes['positions_count'].to_i
        )
      end
    
      render json: result, status: :ok
    end

    def fetch_delivered_expeditions
      expeditions = Expedition
      .where(status: 'delivered')
      .joins(:supplier) # Join suppliers table
      .where(suppliers: { company_id: params[:company_id] }) # Filter by company's suppliers
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
                                  .joins(:expedition)
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

    def fetch_parts_by_supplier
      parts = Part.joins("INNER JOIN parts_suppliers ON parts.id = parts_suppliers.part_id")
                  .where("parts_suppliers.supplier_id = ?", @supplier.id)
  
      render json: parts, status: :ok
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Supplier not found" }, status: :not_found
    rescue => e
      render json: { error: "Internal Server Error: #{e.message}" }, status: :internal_server_error
    end

    def fetch_client_orders_by_company
      # Fetch client orders with associated clients and positions
      client_order_positions = @company.client_orders.includes(client: {}, client_order_positions: [:part])
                                          .flat_map do |order|
        order.client_order_positions.map do |position|
          {
            id: position.id,
            quantity: position.quantity,
            price: position.price,
            delivery_date: position.delivery_date,
            client_name: order.client.name,
            order_number: order.number,
            reference_and_designation: "#{position.part.reference} #{position.part.designation}"
          }
        end
      end
    
      render json: client_order_positions, status: :ok
    end

    def fetch_client_by_name
      client = Client.find_by(name: params[:name])

      render json: client, status: :ok
    end

    def fetch_contacts_by_client
      contacts = @client.contacts

      render json: contacts, status: :ok
    end

    def fetch_supplier_orders_by_company
      supplier_orders = @company.supplier_orders.includes(:supplier, :supplier_order_positions)
    
      supplier_orders_array = supplier_orders.map do |order|
        order.supplier_order_positions.map do |position|
          {
            id: position.id,
            quantity: position.quantity,
            price: position.price,
            delivery_date: position.delivery_date,
            supplier_name: order.supplier.name,
            order_number: order.number,
            reference_and_designation: "#{position.part.reference} #{position.part.designation}"
          }
        end
      end.flatten
    
      render json: supplier_orders_array, status: :ok
    end

    def part_related_data
      @part_searched = Part.includes(:suppliers, :client_orders, :sub_contractors, :logistic_places)
                          .find_by(id: params[:part_id])
    
      if @part_searched
        suppliers = @part_searched.suppliers.uniq
        client = @part_searched.client
        sub_contractors = @part_searched.sub_contractors.uniq
    
        current_supplier_price = @part_searched.current_supplier_price
        current_client_price = @part_searched.current_client_price
    
        render json: @part_searched.as_json.merge(
          suppliers: suppliers.as_json(only: [:name]),
          client: client, 
          sub_contractors: sub_contractors, 
          supplier_price: current_supplier_price, 
          client_price: current_client_price
        )
      else
        render json: { error: "Part not found" }, status: :not_found
      end
    end

    def companies_index
      user_id = @user.id
    
      # Fetch companies where the user does NOT have an account
      @companies = Company.where.not(id: Account.where(user_id: user_id).select(:company_id))
    
      render json: @companies
    end

    def search_company_by_name
      name = params[:name]
  
      company = Company.find_by(name: name)
  
      if company
        render json: company, status: :ok
      else
        render json: { error: 'Company not found' }, status: :not_found
      end
    end

    def client_index
      @clients = Client.where(company_id: params[:company_id])
      render json: @clients
    end

    def supplier_index
      @suppliers = Supplier.where(company_id: params[:company_id])
      render json: @suppliers
    end

    def subcontractors_index
      @subcontractors = SubContractor.where(company_id: params[:company_id])
      render json: @subcontractors
    end

    def logistic_places_index
      @logistic_places = LogisticPlace.where(company_id: params[:company_id])
      render json: @logistic_places
    end
  
    #SPECIFIC INDICES
    def fetch_parts_by_client
      @parts = Part.where( client_id: @client.id )

      render json: @parts, status: :ok
    rescue ActiveRecord::RecordNotFound => e
      render json: { error: e.message }, status: :not_found
    end

    def fetch_parts_by_client_and_consignment_stock
      @parts = Part
        .joins(:consignment_stock_parts) # Ensure we join the `consignment_stock_parts` table
        .where(
          client_id: @client.id,
          consignment_stock_parts: { consignment_stock_id: params[:consignment_stock_id] }
        )
        .where('consignment_stock_parts.current_quantity > 0') # Exclude zero stock quantities
        .select(
          'parts.*',
          'consignment_stock_parts.current_quantity AS quantity' # Use SQL aliasing for stock quantity
        )
    
      render json: @parts.map { |part|
        part.attributes.merge(
          current_quantity: part.attributes['quantity'] # Map the SQL alias to the JSON response
        )
      }, status: :ok
    rescue ActiveRecord::RecordNotFound => e
      render json: { error: e.message }, status: :not_found
    rescue StandardError => e
      render json: { error: e.message }, status: :internal_server_error
    end
  
    def parts_by_supplier_orders
      @parts = Part.joins(:supplier_orders)
              .where(supplier_orders: { id: @supplier_orders.pluck(:id) })
              .distinct
      render json: @parts
    end
  
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

    # Models creations
    def create_expedition_position_history(**params)
      ExpeditionPositionHistory.create!(
        expedition_position_id: params[:expedition_position_id],
        transfer_date: params[:transfer_date],
        delivery_slip: params[:delivery_slip],
        part_id: params[:part_id],
        event_type: params[:event_type],
        location_name: params[:location_name],
        description: params[:description] || nil
      )
    end

    def create_client_position(**params)
      ClientPosition.create!(
        client_id: params[:client_id],
        part_id: params[:part_id],
        expedition_id: params[:expedition_id],
        supplier_order_index_id: params[:supplier_order_index_id],
        quantity: params[:quantity] || 0,
        sorted: params[:sorted] || false,
        is_clone: params[:is_clone] || false
      )
    end
    
    def create_expedition_position(**params)
      new_position = ExpeditionPosition.create!(
        expedition_id: params[:expedition_id],
        supplier_order_index_id: params[:supplier_order_index_id],
        part_id: params[:part_id],
        quantity: params[:quantity],
        is_clone: params[:is_clone],
        finition_status: params[:finition_status]
      )
    
      if params[:destination_type].present?
        case params[:destination_type]
        when "subcontractor"
          subcontractor = SubContractor.find_by(id: params[:subcontractor_id])
          raise ActiveRecord::RecordNotFound, "Subcontractor not found" unless subcontractor
      
          new_position.sub_contractors << subcontractor
        when "logistic_place"
          logistic_place = LogisticPlace.find_by(id: params[:logistic_place_id])
          raise ActiveRecord::RecordNotFound, "Logistic place not found" unless logistic_place
      
          new_position.logistic_places << logistic_place
        else
          raise ArgumentError, "Invalid destination type: #{params[:destination_type]}"
        end
      end
      
      new_position
    end

    # STRONG PARAMS PERMISSIONS 

    def transporter_params
      params.require(:transporter).permit(:name, :is_air, :is_land, :is_sea)
    end

    def client_params
      params.require(:client).permit(:name, :address)
    end

    def supplier_params
      params.require(:supplier).permit(:name, :address)
    end

    def part_params 
      params.require(:part).permit(:reference, :weight, :designation, :material, :drawing, :client_id, :supplier_id)
    end

    def client_order_params
      params.require(:client_order).permit(:number, :price, :client_contact, :order_date, :order_delivery_time, :client_id, :quantity, :transporter, :company_id, :part_id,
        client_order_positions: [:part_id, :price, :quantity, :delivery_date]
      )
    end

    def subcontractor_params
      params.require(:subcontractor).permit(:name, :address, :knowledge)
    end

    def logistic_place_params
      params.require(:logistic_place).permit(:name, :address, :knowledge)
    end

    def supplier_order_params
      params.require(:supplier_order).permit(:number, :price, :quantity_status, :supplier_contact, :order_date, :order_delivery_time, :estimated_delivery_time, :estimated_departure_time, :supplier_id, :quantity, :transporter, :company_id, :part_id, 
        supplier_order_positions_attributes: [
          :part_id,
          :price,
          :quantity,
          :delivery_date,
          :original_quantity
        ] )
    end

    def company_params
      params.require(:company).permit(
        :name,
        :legal_structure,
        :address,
        :city,
        :postal_code,
        :country,
        :tax_id,
        :registration_number,
        :website,
        :authorized_signatory,
        :tax_rate,
        :invoice_prefix,
        :invoice_terms,
        :legal_notice
      )
    end

    def expedition_params
      params.require(:expedition).permit(:real_departure_time, :price, :number, :estimated_departure_time, :arrival_time, :transporter)
    end

    # SETTING MODELS FOR OTHER FUNCTIONS

    def set_company
      @company = Company.find_by(id: params[:company_id])
    end

    def set_part_by_company
      @part = Part.find_by(id: params[:part_id], company_id: params[:company_id])
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
      @supplier = Supplier.find_by(id: params[:supplier_id])
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
  