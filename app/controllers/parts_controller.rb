class PartsController < ApplicationController
    before_action :set_user_by_id, only: [:create_company, :companies_index, :owner_companies_index]
    before_action :set_supplier, only: [:fetch_parts_by_supplier]
    before_action :set_client, only: [:fetch_stocks_by_client, :fetch_expedition_positions_by_client, :fetch_client_orders_by_client, :fetch_contacts_by_client, :create_part, :fetch_parts_by_client_and_consignment_stock, :fetch_parts_by_client, :standard_stocks_positions_by_client, :consignment_stocks_positions_by_client, :fetch_standard_stocks_by_client, :fetch_consignment_stocks_by_client]
    before_action :set_supplier_orders, only: [:parts_by_supplier_orders]
    before_action :set_client_orders, only: [:parts_by_client_orders]
    before_action :set_part, only: [:fetch_calculate_part_stocks, :consignment_stocks_positions_by_client, :fetch_client_order_positions_by_part, :standard_stocks_positions_by_client, :consignment_stocks_positions_by_client, :fetch_unsorted_client_positions, :fetch_expeditions_supplier_order_indices_by_part, :fetch_logistic_places_by_part, :fetch_sub_contractors_by_part, :fetch_supplier_orders_by_part]
    before_action :set_expedition, only: [:fetch_expedition_orders, :dispatch_expedition]
    before_action :set_company, only: [
      :archive_expedition_position,
      :archive_client_position,
      :create_expedition,
      :fetch_all_parts_stocks,
      :fetch_margins_by_part,
      :fetch_revenue_vs_costs,
      :fetch_sales_distribution,
      :fetch_parts_sold_by_month,
      :fetch_order_slips_by_company,
      :fetch_delivery_slips_by_company,
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
      :fetch_client_order_positions_by_part, 
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

          if params[:lifecycles]
            params[:lifecycles].each_with_index do |step, index|
              entity_class = step["entity_type"].constantize rescue nil # Prevent errors
              next unless entity_class && entity_class.exists?(step["entity_id"])
            
              @part.part_lifecycles.create!(
                step_name: step["step_name"],
                entity_type: step["entity_type"], 
                entity_id: step["entity_id"],
                sequence_order: index + 1
              )
            end
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
              next if stock_params[:address].blank? || stock_params[:name].blank?

              @client.consignment_stocks.create!(
                address: stock_params[:address],
                name: stock_params[:name],
              )
            end
          end

          # Process standard stocks
          if params[:client][:standard_stocks]
            params[:client][:standard_stocks].each do |stock_params|
              next if stock_params[:address].blank? || stock_params[:name].blank?
              
              @client.standard_stocks.create!(
                address: stock_params[:address],
                name: stock_params[:name]
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

    def create_logistic_place
      merged_params = logistic_place_params.merge(company: @company)

      @logistic_place = LogisticPlace.new(merged_params)

      if @logistic_place.save
        if params[:logistic_place][:contacts]
          params[:logistic_place][:contacts].each do |contact_params|
            @logistic_place.contacts.create!(
              email: contact_params[:email],
              first_name: contact_params[:first_name],
              last_name: contact_params[:last_name],
              role: contact_params[:role]
            )            
          end
        end
        render json: { success: 'logistic_place created successfully', logistic_place: @logistic_place }, status: :created
      else
        render json: { errors: @logistic_place.errors.full_messages }, status: :unprocessable_entity
      end
    end

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

        render json: { status: 'ok', success: @consumption }, status: :ok
      rescue ActiveRecord::RecordInvalid => e
        render json: { error: e.message }, status: :unprocessable_entity
      end
    end

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

    def complete_client_order_position
      position = ClientOrderPosition.find_by(id: params[:position_id])
    
      if position
        ActiveRecord::Base.transaction do
          # Mark the position as delivered
          position.update!(status: 'delivered')
          position.update!(real_delivery_time: params[:delivery_date]) if params[:delivery_date]
    
          # Check if all positions belonging to the client order are delivered
          client_order = position.client_order
          if client_order.client_order_positions.all? { |pos| pos.status == 'delivered' }
            client_order.update!(order_status: 'delivered')
          end
        end

        render json: { message: "Order position updated successfully", position: position }, status: :ok
      else
        render json: { error: 'Position not found' }, status: :not_found
      end
    rescue ActiveRecord::RecordInvalid => e
      render json: { errors: e.message }, status: :unprocessable_entity
    end

    def complete_supplier_order_position
      position = SupplierOrderPosition.find_by(id: params[:position_id])
    
      if position
        ActiveRecord::Base.transaction do
          # Mark the position as delivered
          delivery_date = params[:delivery_date] || Date.today
          position.update!(delivered: true, status: 'completed', real_delivery_date: delivery_date)
    
          # Check if all positions belonging to the supplier order are delivered
          supplier_order = position.supplier_order
          all_positions_delivered = supplier_order.supplier_order_positions.all?(&:delivered)
    
          # Update the supplier order if all positions are delivered
          supplier_order.update!(fully_delivered: all_positions_delivered)
    
          render json: {
            success: "Position #{position.id} marked as delivered.",
            supplier_order_fully_delivered: all_positions_delivered
          }, status: :ok
        end
      else
        render json: { error: 'Position not found' }, status: :not_found
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
      @expedition = Expedition.new(expedition_params.merge(company: @company))
      transporter = Transporter.find_by(id: params[:transporter_id])
      @expedition.transporter = transporter
    
      # Ensure quantities are not nil or empty
      ids = params[:supplier_order_position_ids].split(',').map(&:strip)
      quantities = params[:supplier_order_position_quantities].presence&.split(',')&.map(&:strip)&.map(&:to_i) || []
      partials = params[:supplier_order_position_partials].split(',').map(&:strip).map { |p| ActiveModel::Type::Boolean.new.cast(p) }
    
      ActiveRecord::Base.transaction do
        if @expedition.save
          @expedition.update!(status: 'undelivered')
    
          ids.each_with_index do |position_id, index|
            supplier_order_position = SupplierOrderPosition.find(position_id)
            shipped_quantity = quantities[index] || 0
            is_partial = partials[index]

            supplier_order_index = SupplierOrderIndex.create!(
              supplier_order_position: supplier_order_position,
              quantity: shipped_quantity,
              quantity_status: is_partial ? "partial" : "full",
              status: "transit",
              part: supplier_order_position.part,
              expedition: @expedition
            )
    
            remaining_quantity = (supplier_order_position.quantity || 0) - shipped_quantity
    
            new_status =
            if remaining_quantity <= 0 || !is_partial
              "completed"
            elsif remaining_quantity > 0 || is_partial
              "partial_sent_and_production"
            else
              "production"
            end
    
            supplier_order_position.update!(
              quantity: remaining_quantity,
              status: new_status
            )
          end
    
          render json: { success: "Expedition created successfully", expedition: @expedition }, status: :created
        else
          render json: { errors: @expedition.errors.full_messages }, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: e.message }, status: :unprocessable_entity
      rescue ArgumentError => e
        render json: { errors: e.message }, status: :unprocessable_entity
      end
    end

    def dispatch_expedition
      service = ExpeditionDispatcherService.new(@expedition, params)
      result = service.call
  
      if result[:success]
        render json: { success: result[:success] }, status: :ok
      else
        render json: { error: result[:error] }, status: :unprocessable_entity
      end
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
    
      is_clone = params[:is_clone].present? ? params[:is_clone] : false
      logistic_place_id = params[:logistic_place_id]
      subcontractor_id = params[:subcontractor_id]
    
      location_name = resolve_destination_name(destination_type, logistic_place_id, subcontractor_id, destination_name)
      return render json: { error: "Invalid destination or not found" }, status: :not_found unless location_name
    
      ActiveRecord::Base.transaction do
        total_quantity = expedition_position.quantity
    
        if transfer_quantity == total_quantity
          expedition_position.sub_contractors.clear
          expedition_position.logistic_places.clear
    
          case destination_type
          when "subcontractor"
            subcontractor = SubContractor.find_by(id: subcontractor_id)
            raise ActiveRecord::RecordNotFound, "Subcontractor not found" unless subcontractor
    
            expedition_position.sub_contractors << subcontractor
    
          when "logistic_place"
            logistic_place = LogisticPlace.find_by(id: logistic_place_id)
            raise ActiveRecord::RecordNotFound, "Logistic place not found" unless logistic_place
    
            expedition_position.logistic_places << logistic_place
    
          when "client"
            client = Client.find_by(name: destination_name)
            raise ActiveRecord::RecordNotFound, "Client not found" unless client
    
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
            raise ActiveRecord::RecordInvalid, "Invalid destination type"
          end
        elsif transfer_quantity < total_quantity
          remaining_quantity = total_quantity - transfer_quantity
          expedition_position.update!(quantity: remaining_quantity)
    
          if destination_type == "client"
            client = Client.find_by(name: destination_name)
            raise ActiveRecord::RecordNotFound, "Client not found" unless client
    
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
        else
          raise ActiveRecord::RecordInvalid, "Transfer quantity exceeds available quantity"
        end
      end
    
      render json: { success: "Position transferred successfully" }, status: :ok
    rescue StandardError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

    def transfer_position_from_client
      client_position_id = params[:client_position_id]
      transfer_quantity = params[:quantity].to_i
      destination_type = params[:destination_type]
      destination_name = params[:destination_name]
      logistic_place_id = params[:logistic_place_id]
      subcontractor_id = params[:subcontractor_id]
      transfer_date = params[:transfer_date] || Date.today
      delivery_slip = params[:delivery_slip]
    
      client_position = ClientPosition.find_by(id: client_position_id)
      return render json: { error: "Client position not found" }, status: :not_found unless client_position
    
      total_quantity = client_position.quantity
      if transfer_quantity > total_quantity
        return render json: { error: "Transfer quantity exceeds available quantity" }, status: :unprocessable_entity
      end
    
      location_name = resolve_destination_name(destination_type, logistic_place_id, subcontractor_id, destination_name)
      return render json: { error: "Invalid destination or not found" }, status: :not_found unless location_name
    
      ActiveRecord::Base.transaction do
        # Handle full transfer
        if transfer_quantity == total_quantity
          case destination_type
          when "subcontractor"
            subcontractor = SubContractor.find_by(id: subcontractor_id)
            return render json: { error: "Subcontractor not found" }, status: :not_found unless subcontractor
    
            create_expedition_position(
              expedition_id: client_position.expedition_id,
              supplier_order_index_id: client_position.supplier_order_index_id,
              part_id: client_position.part_id,
              quantity: transfer_quantity,
              is_clone: client_position.is_clone,
              destination_type: "subcontractor",
              subcontractor_id: subcontractor.id
            )
    
          when "logistic_place"
            logistic_place = LogisticPlace.find_by(id: logistic_place_id)
            return render json: { error: "Logistic place not found" }, status: :not_found unless logistic_place
    
            create_expedition_position(
              expedition_id: client_position.expedition_id,
              supplier_order_index_id: client_position.supplier_order_index_id,
              part_id: client_position.part_id,
              quantity: transfer_quantity,
              is_clone: client_position.is_clone,
              destination_type: "logistic_place",
              logistic_place_id: logistic_place.id
            )
    
          else
            return render json: { error: "Invalid destination type" }, status: :unprocessable_entity
          end
    
          # Remove the client position since all quantity is transferred
          client_position.destroy!
    
        # Handle partial transfer
        elsif transfer_quantity < total_quantity
          # Update the remaining quantity for the client position
          remaining_quantity = total_quantity - transfer_quantity
          client_position.update!(quantity: remaining_quantity)
    
          case destination_type
          when "subcontractor"
            subcontractor = SubContractor.find_by(id: subcontractor_id)
            return render json: { error: "Subcontractor not found" }, status: :not_found unless subcontractor
    
            create_expedition_position(
              expedition_id: client_position.expedition_id,
              supplier_order_index_id: client_position.supplier_order_index_id,
              part_id: client_position.part_id,
              quantity: transfer_quantity,
              is_clone: client_position.is_clone,
              finition_status: "draft",
              destination_type: "subcontractor",
              subcontractor_id: subcontractor.id
            )
    
          when "logistic_place"
            logistic_place = LogisticPlace.find_by(id: logistic_place_id)
            return render json: { error: "Logistic place not found" }, status: :not_found unless logistic_place
    
            create_expedition_position(
              expedition_id: client_position.expedition_id,
              supplier_order_index_id: client_position.supplier_order_index_id,
              part_id: client_position.part_id,
              quantity: transfer_quantity,
              is_clone: client_position.is_clone,
              finition_status: "draft",
              destination_type: "logistic_place",
              logistic_place_id: logistic_place.id
            )
    
          else
            return render json: { error: "Invalid destination type" }, status: :unprocessable_entity
          end
        end
      end
    
      render json: { success: "Transfer from client completed successfully" }, status: :ok
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

    def parts_by_company
      @parts = Part
        .joins(<<-SQL)
          LEFT JOIN client_order_positions ON client_order_positions.part_id = parts.id
          LEFT JOIN supplier_order_positions ON supplier_order_positions.part_id = parts.id
          LEFT JOIN clients ON parts.client_id = clients.id
          LEFT JOIN client_positions ON client_positions.part_id = parts.id
          LEFT JOIN parts_suppliers ON parts.id = parts_suppliers.part_id
          LEFT JOIN suppliers ON parts_suppliers.supplier_id = suppliers.id
        SQL
        .where(company_id: @company.id)
        .select(
          'parts.*',
          'MAX(client_order_positions.price) AS latest_client_price',
          'MAX(supplier_order_positions.price) AS latest_supplier_price',
          'COUNT(CASE WHEN client_positions.sorted = false THEN 1 END) AS unsorted_positions_count', # Count unsorted positions
          'clients.name AS client_name',
          'ARRAY_AGG(DISTINCT suppliers.id) AS supplier_ids'
        )
        .group('parts.id, clients.name') # Group by parts.id and clients.name for aggregation
    
      render json: @parts.map { |part|
        part.attributes.merge(
          latest_client_price: part.attributes['latest_client_price'],
          latest_supplier_price: part.attributes['latest_supplier_price'],
          unsorted_positions_count: part.attributes['unsorted_positions_count'].to_i,
          client_name: part.attributes['client_name'],
          supplier_ids: part.attributes['supplier_ids'] || []
        )
      }
    end

    def fetch_delivery_slips_by_company
      delivery_slips = @company.delivery_slips.includes(:client, :part, :logistic_place)
      render json: delivery_slips, status: :ok

    rescue ActiveRecord::RecordNotFound
      render json: { error: "Invalid Company ID" }, status: :not_found
    end

    def fetch_order_slips_by_company
      order_slips = @company.order_slips
                            .includes(supplier_order: :supplier, supplier_order_position: :part)
                            .map do |order_slip|
        {
          id: order_slip.id,
          delivery_date: order_slip.supplier_order_position&.delivery_date,
          transit_method: fetch_transit_methods(order_slip),
          transporter: order_slip.transporter&.name,
          supplier_order_number: order_slip.supplier_order&.number,
          supplier_name: order_slip.supplier_order&.supplier&.name,
          reference_and_designation: "#{order_slip.supplier_order_position&.part&.reference} #{order_slip.supplier_order_position&.part&.designation}"
        }
      end
    
      render json: order_slips, status: :ok
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Invalid Company ID" }, status: :not_found
    end

    def fetch_unsorted_client_positions
      unsorted_positions = ClientPosition.includes(:part).where(part_id: params[:part_id], sorted: false, archived: false)
    
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
      client_order_positions = ClientOrderPosition
                                 .joins(client_order: :client)
                                 .joins(:part)
                                 .where(clients: { company_id: @company.id })
                                 .where(status: 'undelivered')
                                 .where(archived: false)
                                 .select(
                                   'client_order_positions.id AS position_id',
                                   'client_orders.id AS order_id',
                                   'client_orders.number AS order_number',
                                   'clients.name AS client_name',
                                   'client_order_positions.quantity AS position_quantity',
                                   'client_order_positions.delivery_date AS position_delivery_date',
                                   'parts.reference AS part_reference',
                                   'parts.designation AS part_designation',
                                   'parts.id AS part_id'
                                 )
                                 .order('client_order_positions.delivery_date ASC')
    
      # Format the results
      formatted_positions = client_order_positions.map do |position|
        {
          id: position.position_id,
          order_id: position.order_id,
          order_number: position.order_number,
          client_name: position.client_name,
          position_quantity: position.position_quantity,
          position_delivery_date: position.position_delivery_date,
          part_reference: position.part_reference,
          part_designation: position.part_designation,
          available_stock: calculate_available_stock(position.part_id)
        }
      end
    
      render json: formatted_positions, status: :ok
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Company not found' }, status: :not_found
    end

    def standard_stocks_positions_by_client
      standard_stocks = StandardStock.where(client_id: @client.id)
                                     .includes(:client_positions)
  
      result = standard_stocks.map do |stock|
        {
          id: stock.id,
          address: stock.address,
          name: stock.name,
          client_positions: stock.client_positions.where(part_id: @part_searched.id, archived: false).map do |position|
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
          name: stock.name,
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
          client_positions: stock.client_positions.where(part_id: @part_searched.id, archived: false).map do |position|
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
      urgent_client_order_positions = ClientOrderPosition
        .joins(client_order: { client: :company })
        .where(clients: { company_id: params[:company_id] })
        .distinct
        .where('client_order_positions.delivery_date >= ? AND client_order_positions.delivery_date <= ?', Date.today, Date.today + 30.days)

      future_client_order_positions = ClientOrderPosition
        .joins(client_order: { client: :company })
        .where(clients: { company_id: params[:company_id] })
        .distinct
        .where('client_order_positions.delivery_date >= ? AND client_order_positions.delivery_date <= ?', Date.today, Date.today + 180.days)

      delayed_order_positions = ClientOrderPosition
        .joins(client_order: { client: :company })
        .where(clients: { company_id: params[:company_id] })
        .distinct
        .where('client_order_positions.delivery_date < ?', Date.today)
        .where(status: 'undelivered')

      undelivered_expeditions = Expedition
        .joins(supplier_order_indices: { supplier_order_position: { supplier_order: :supplier } })
        .where(status: 'undelivered', suppliers: { company_id: params[:company_id] })
        .distinct
        .count
    
      urgent_orders = urgent_client_order_positions.where(status: 'undelivered').count
      future_orders = future_client_order_positions.where(status: 'undelivered').count
      delayed_orders = delayed_order_positions.where(status: 'undelivered').count
    
      render json: {
        delayedOrders: delayed_orders,
        totalActiveOrders: urgent_orders,
        futureOrders: future_orders,
        runningExpeditions: undelivered_expeditions
      }
    end

    def fetch_position_history
      client_position = ClientPosition.includes(:supplier_order_index).find_by(id: params[:client_position_id])
    
      # Check if the client_position exists
      return render json: { error: "ClientPosition not found" }, status: :not_found unless client_position
    
      # Retrieve related records
      supplier_order_index = client_position&.supplier_order_index
      expedition = Expedition.find_by(id: client_position.expedition_id)
      supplier_order = supplier_order_index&.supplier_order_position&.supplier_order
      client_order = ClientOrder.joins(:client_order_positions)
                                .find_by(client_order_positions: { part_id: client_position&.part_id })
    
      # Retrieve expedition position histories linked to either expedition or client position
      expedition_position_histories = ExpeditionPositionHistory
                                        .where(client_position_id: client_position.id)
                                        .or(
                                          ExpeditionPositionHistory.where(expedition_position_id: ExpeditionPosition.where(expedition_id: expedition&.id).pluck(:id))
                                        )
                                        .order(created_at: :asc)
                                        .map do |history|
        duration = history.updated_at ? ((history.updated_at - history.created_at) / 1.day).round(2) : 'Ongoing'
    
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
        counts: (expedition_position_histories.length || 0) +
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
          client_positions: stock.client_positions.where(archived: false).pluck(
            :id, :part_id, :quantity, :sorted
          ).map do |id, part_id, quantity, sorted|
            { id: id, part_id: part_id, quantity: quantity, sorted: sorted }
          end
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
          client_positions: stock.client_positions.where(archived: false).pluck(
            :id, :part_id, :quantity, :sorted
          ).map do |id, part_id, quantity, sorted|
            { id: id, part_id: part_id, quantity: quantity, sorted: sorted }
          end
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

    def fetch_calculate_part_stocks
      return render json: { error: 'Part not found' }, status: :not_found unless @part_searched
    
      stock_service = StockService.new(part: @part_searched)
      result = stock_service.fetch_calculate_part_stocks
    
      render json: result, status: :ok
    end

    def fetch_all_parts_stocks
      return render json: { error: 'Company not found' }, status: :not_found unless @company
    
      stock_service = StockService.new(company: @company)
      stocks = stock_service.fetch_all_parts_stocks
    
      render json: stocks, status: :ok
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
        .where(archived: false)
        .select(
          'supplier_order_positions.*',
          'supplier_orders.number AS supplier_order_number',
          'supplier_orders.status AS supplier_order_status',
          'parts.reference AS part_reference',
          'parts.designation AS part_designation',
          'suppliers.name AS supplier_name'
        )
    
      render json: @supplier_orders_positions.map do |position|
        position.attributes.merge(
          supplier_order_number: position.attributes['supplier_order_number'],
          supplier_order_status: position.attributes['supplier_order_status'],
          part_reference: position.attributes['part_reference'],
          part_designation: position.attributes['part_designation'],
          supplier_name: position.attributes['supplier_name']
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
                       .where(archived: false)
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
  
    def fetch_client_order_positions_by_part
      client_order_positions = ClientOrderPosition
        .joins(client_order: :client) # Join client through client_order
        .joins(:part)                # Join the part table
        .where(part_id: params[:part_id]) # Use params[:part_id] for the filter
        .where(archived: false)
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
        .includes(
          :transporter,
          supplier_order_indices: {
            part: {},
            supplier_order_position: { supplier_order: { supplier: {} } }
          }
        )
        .where(status: 'undelivered', company_id: params[:company_id])
        .order(:created_at)
    
      result = expeditions.map do |expedition|
        {
          id: expedition.id,
          number: expedition.number,
          status: expedition.status,
          transporter_name: expedition.transporter&.name,
          supplier_names: expedition.supplier_order_indices
                                  .map { |index| index.supplier_order_position.supplier_order.supplier.name }
                                  .uniq, # Ensures unique supplier names
          real_departure_time: expedition.real_departure_time,
          estimated_arrival_time: expedition.estimated_arrival_time,
          expedition_positions: expedition.supplier_order_indices.map do |index|
            {
              id: index.id,
              quantity: index.quantity,
              quantity_status: index.quantity_status,
              part_id: index.part_id,
              part_reference: index.part.reference,
              part_designation: index.part.designation,
              supplier_order_number: index.supplier_order_position.supplier_order.number
            }
          end
        }
      end
    
      render json: result, status: :ok
    end

    def fetch_delivered_expeditions
      expeditions = Expedition
      .includes(
        :transporter,
        supplier_order_indices: {
          part: {},
          supplier_order_position: { supplier_order: { supplier: {} } }
        }
      )
      .where(status: 'delivered', company_id: params[:company_id])
      .order(:created_at)
    
      result = expeditions.map do |expedition|
      {
        id: expedition.id,
        number: expedition.number,
        status: expedition.status,
        transporter_name: expedition.transporter&.name,
        supplier_names: expedition.supplier_order_indices.map { |index| index.supplier_order_position.supplier_order.supplier.name }.uniq,
        real_departure_time: expedition.real_departure_time,
        arrival_time: expedition.arrival_time,
        expedition_positions: expedition.supplier_order_indices.map do |index|
        {
          id: index.id,
          part_id: index.part_id,
          quantity: index.quantity,
          part_reference: index.part.reference, # Part Reference
          part_designation: index.part.designation, # Part Designation
          supplier_order_number: index.supplier_order_position.supplier_order.number # Supplier Order Number
        }
        end
      }
      end
    
      render json: result, status: :ok
    end

    def fetch_stocks_by_client
      stocks = @client.standard_stocks + @client.consignment_stocks
    
      render json: stocks, status: :ok
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Client not found" }, status: :not_found
    end

    #FILTERED BY PART
    def fetch_expeditions_supplier_order_indices_by_part
      @supplier_order_indices = SupplierOrderIndex
            .joins(supplier_order_position: { supplier_order: :supplier })
            .joins(expedition: :transporter)
            .where(part_id: @part_searched.id)
            .select(
            'supplier_order_indices.*',
            'expeditions.estimated_arrival_time AS estimated_arrival_time',
            'supplier_orders.number AS supplier_order_number',
            'suppliers.name AS supplier_name',
            'expeditions.real_departure_time AS real_departure_time',
            'transporters.name AS transporter_name',
            'supplier_order_positions.quantity AS supplier_order_quantity',
            'expeditions.number AS expedition_number'
            )
    
      render json: @supplier_order_indices.map do |index|
      index.attributes.merge(
      estimated_arrival_time: index.attributes['estimated_arrival_time'],
      supplier_order: {
      number: index.attributes['supplier_order_number'],
      name: index.attributes['supplier_name'],
      quantity: index.attributes['supplier_order_quantity']
      },
      real_departure_time: index.attributes['real_departure_time'],
      transporter_name: index.attributes['transporter_name'],
      expedition_number: index.attributes['expedition_number']
      )
      end
    end

    def fetch_expedition_position_by_sub_contractor
      part_id = params[:part_id]
    
      expedition_positions = ExpeditionPosition.joins(:sub_contractors, :expedition)
                                               .where(part_id: part_id, archived: false)
                                               .select('expedition_positions.*, expeditions.number AS expedition_number')
    
      result = expedition_positions.group_by { |position| position.sub_contractors.first }.map do |subcontractor, positions|
        {
          subcontractor_name: subcontractor.name,
          subcontractor_id: subcontractor.id,
          positions: positions.map do |position|
            {
              expedition_position_id: position.id,
              part_id: position.part_id,
              expedition_number: position.expedition_number,
              quantity: position.quantity,
              subcontractor_name: subcontractor.name,
              subcontractor_id: subcontractor.id
            }
          end
        }
      end
    
      render json: result, status: :ok
    end

    def fetch_expedition_position_by_logistic_place
      part_id = params[:part_id]
    
      expedition_positions = ExpeditionPosition.joins(:logistic_places, :expedition)
                                               .where(part_id: part_id, archived: false)
                                               .select('expedition_positions.*, expeditions.number AS expedition_number')
    
      result = expedition_positions.group_by { |position| position.logistic_places.first }
                                    .map do |logistic_place, positions|
        {
          logistic_place_name: logistic_place.name,
          logistic_place_id: logistic_place.id,
          positions: positions.map do |position|
            {
              expedition_position_id: position.id,
              expedition_id: position.expedition_id,
              expedition_number: position.expedition_number,
              quantity: position.quantity,
              part_id: position.part_id,
              logistic_place_name: logistic_place.name,
              logistic_place_id: logistic_place.id,
            }
          end
        }
      end
    
      render json: result, status: :ok
    end

    def fetch_client_orders_by_client
      client_orders = @client.client_orders.map do |order|
        {
          id: order.id,
          order_number: order.number,
          total_quantity: order.client_order_positions.sum(&:quantity),
          total_price: order.client_order_positions.sum { |pos| pos.quantity * pos.price },
          delivery_date: order.delivery_date
        }
      end
    
      render json: client_orders, status: :ok
    end

    def fetch_expedition_positions_by_client
      expedition_positions = ExpeditionPosition
        .joins(part: :client)
        .joins('LEFT JOIN expedition_positions_sub_contractors ON expedition_positions.id = expedition_positions_sub_contractors.expedition_position_id')
        .joins('LEFT JOIN sub_contractors ON sub_contractors.id = expedition_positions_sub_contractors.sub_contractor_id')
        .joins('LEFT JOIN expedition_positions_logistic_places ON expedition_positions.id = expedition_positions_logistic_places.expedition_position_id')
        .joins('LEFT JOIN logistic_places ON logistic_places.id = expedition_positions_logistic_places.logistic_place_id')
        .joins(:expedition)
        .where(parts: { client_id: @client.id })
        .where(archived: false)
        .select(
          'DISTINCT expedition_positions.id AS id',
          'parts.reference AS part_reference',
          'parts.designation AS part_designation',
          'expedition_positions.quantity AS quantity',
          'expedition_positions.sorted AS sorted',
          'expeditions.number AS expedition_number',
          'expeditions.real_departure_time AS delivery_date',
          'sub_contractors.name AS subcontractor_name',
          'sub_contractors.id AS subcontractor_id',
          'logistic_places.name AS logistic_place_name',
          'logistic_places.id AS logistic_place_id'
        )
    
      subcontractor_positions = expedition_positions.group_by(&:subcontractor_id)    
      logistic_place_positions = expedition_positions.group_by(&:logistic_place_id)
      unassociated_positions = expedition_positions.select do |pos|
        pos.subcontractor_id.nil? && pos.logistic_place_id.nil?
      end
    
      # Prepare subcontractor result, filtering out nil values
      subcontractor_result = subcontractor_positions.map do |subcontractor_id, positions|
        next if subcontractor_id.nil?
    
        {
          subcontractor_id: subcontractor_id,
          subcontractor_name: positions.first.subcontractor_name,
          positions: positions.map do |pos|
            {
              expedition_position_id: pos.id,
              part_reference: pos.part_reference,
              part_designation: pos.part_designation,
              quantity: pos.quantity,
              expedition_number: pos.expedition_number,
              delivery_date: pos.delivery_date
            }
          end
          }
      end.compact # Removes nil from the result
    
      # Prepare logistic place result, filtering out nil values
      logistic_place_result = logistic_place_positions.map do |logistic_place_id, positions|
        next if logistic_place_id.nil?
    
        {
          logistic_place_id: logistic_place_id,
          logistic_place_name: positions.first.logistic_place_name,
          positions: positions.map do |pos|
            {
              expedition_position_id: pos.id,
              part_reference: pos.part_reference,
              part_designation: pos.part_designation,
              quantity: pos.quantity,
              expedition_number: pos.expedition_number,
              delivery_date: pos.delivery_date
            }
          end
          }
      end.compact
    
      unassociated_result = unassociated_positions.map do |pos|
        {
          expedition_position_id: pos.id,
          part_reference: pos.part_reference,
          part_designation: pos.part_designation,
          quantity: pos.quantity,
          expedition_number: pos.expedition_number,
          delivery_date: pos.delivery_date
        }
      end

      render json: {
        subcontractors: subcontractor_result,
        logistic_places: logistic_place_result,
        unassociated_positions: unassociated_result
      }, status: :ok
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
        order.client_order_positions.where(archived: false).map do |position|
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

    def fetch_contacts_by_supplier_order
      supplier_order = SupplierOrder.find_by(id: params[:supplier_order_id])
      supplier = supplier_order.supplier

      contacts = supplier.contacts

      render json: {
        contacts: contacts, 
        supplier: supplier
      }, status: :ok
    end

    def fetch_supplier_orders_by_company
      supplier_orders = @company.supplier_orders.includes(:supplier, :supplier_order_positions)
                                                .where(supplier_order_positions: { archived: false })
    
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

    def fetch_sales_distribution
      sales_data = ClientOrderPosition
        .joins(client_order: :client)
        .where(clients: { company_id: @company.id })
        .where(archived: false)
        .group("clients.name")
        .select("clients.name AS client, SUM(client_order_positions.quantity) AS total_sales")
        .order("total_sales DESC")
    
      render json: sales_data
    end

    def fetch_margins_by_part
      if params[:client_id].present?
        parts = Part.where(company_id: @company.id, client_id: params[:client_id])
      else
        parts = Part.where(company_id: @company.id)
      end
    
      return render json: { error: "No parts found" }, status: :not_found if parts.empty?
    
      margins = parts.map do |part|
      last_client_price = ClientOrderPosition
        .where(part_id: part.id)
        .order(created_at: :desc)
        .limit(1)
        .pluck(:price)
        .first || 0
    
      last_supplier_price = SupplierOrderPosition
        .where(part_id: part.id)
        .order(created_at: :desc)
        .limit(1)
        .pluck(:price)
        .first || 0
    
      margin = last_client_price - last_supplier_price
    
      {
        part_reference: part.reference,
        part_designation: part.designation,
        last_client_price: last_client_price,
        last_supplier_price: last_supplier_price,
        margin: margin
      }
      end
    
      render json: margins
    end

    def fetch_revenue_vs_costs
      revenue_vs_costs = ClientOrder
        .joins(:client)
        .where(clients: { company_id: @company.id })
        .where.not(order_date: nil)  # 🚀 Ensure valid dates!
        .group("TO_CHAR(client_orders.order_date, 'YYYY-MM')")
        .select("TO_CHAR(client_orders.order_date, 'YYYY-MM') AS month, SUM(client_orders.price) AS revenue")
        .order("month ASC")
    
      render json: revenue_vs_costs
    end

    def fetch_parts_sold_by_month
      parts_sold = ClientOrderPosition
        .joins(client_order: :client)
        .joins(:part) # Join parts table explicitly
        .where(clients: { company_id: params[:company_id] })
        .where.not(client_order_positions: { status: 'canceled' }) # Avoid canceled orders
    
      # Apply client_id filter if provided
      parts_sold = parts_sold.where(clients: { id: params[:client_id] }) if params[:client_id].present?
    
      parts_sold = parts_sold
        .group(Arel.sql("DATE_TRUNC('month', client_order_positions.delivery_date), parts.reference, parts.designation"))
        .order(Arel.sql("DATE_TRUNC('month', client_order_positions.delivery_date)"))
        .select(
          Arel.sql("DATE_TRUNC('month', client_order_positions.delivery_date) AS month"),
          "parts.reference AS part_reference",
          "parts.designation AS part_designation",
          "SUM(client_order_positions.quantity) AS quantity"
        )
    
      render json: parts_sold.map { |record|
        {
          month: record.month.strftime("%Y-%m"), # Format YYYY-MM
          part_reference: record.part_reference,
          part_designation: record.part_designation,
          quantity: record.quantity
        }
      }, status: :ok
    end

    def part_related_data
      @part_searched = Part.includes(:suppliers, :client_orders, :sub_contractors, :logistic_places)
                          .find_by(id: params[:part_id])
    
      if @part_searched
        suppliers = @part_searched.suppliers.select(:id, :name)
        client = @part_searched.client
        sub_contractors = @part_searched.sub_contractors
    
        last_supplier_order_price = SupplierOrderPosition.where(part_id: @part_searched.id)
        .order(created_at: :desc)
        .limit(1)
        .pluck(:price)
        .first

        last_client_order_price = ClientOrderPosition.where(part_id: @part_searched.id)
        .order(created_at: :desc)
        .limit(1)
        .pluck(:price)
        .first

        lifecycle_steps = @part_searched.part_lifecycles.order(sequence_order: :asc).map do |step|
          entity_name = case step.entity_type
                        when 'Supplier'
                          Supplier.find_by(id: step.entity_id)&.name
                        when 'Client'
                          Client.find_by(id: step.entity_id)&.name
                        when 'SubContractor'
                          SubContractor.find_by(id: step.entity_id)&.name
                        when 'LogisticPlace'
                          LogisticPlace.find_by(id: step.entity_id)&.name
                        else
                          nil
                        end
    
          {
            id: step.id,
            step_name: step.step_name,
            entity_type: step.entity_type,
            entity_id: step.entity_id,
            entity_name: entity_name,  # Dynamically fetch entity name
            sequence_order: step.sequence_order
          }
        end
    
        render json: @part_searched.as_json.merge(
          suppliers: suppliers,
          client: client, 
          sub_contractors: sub_contractors, 
          current_supplier_price: last_supplier_order_price, 
          current_client_price: last_client_order_price,
          lifecycle_steps: lifecycle_steps
        )
      else
        render json: { error: "Part not found" }, status: :not_found
      end
    end

    def companies_index
      @companies = Company.where.not(id: Account.where(user_id: @user.id).select(:company_id))
      render json: @companies
    end

    def owner_companies_index
      @companies = Company.joins(:accounts)
                          .where(accounts: { user_id: @user.id, is_owner: true })
                          .distinct
    
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

    def fetch_consumptions_by_consignment_stock
      consignment_stock = ConsignmentStock.find_by(id: params[:consignment_stock_id], client_id: params[:client_id])
    
      unless consignment_stock
        return render json: { error: "Consignment stock not found or does not belong to the client" }, status: :not_found
      end
    
      consumptions = ConsignmentConsumption
        .includes(consignment_consumption_positions: :part)
        .where(consignment_stock_id: consignment_stock.id)
        .order(created_at: :desc)
    
      result = consumptions.map do |consumption|
        {
          id: consumption.id,
          number: consumption.number,
          begin_date: consumption.begin_date,
          end_date: consumption.end_date,
          created_at: consumption.created_at,
          parts: consumption.consignment_consumption_positions.map do |position|
            {
              part_id: position.part_id,
              part_reference: position.part.reference,
              part_designation: position.part.designation,
              quantity: position.quantity,
              price: position.price
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
          'consignment_stock_parts.current_quantity AS quantity',
          "(SELECT client_order_positions.price 
            FROM client_order_positions 
            WHERE client_order_positions.part_id = parts.id 
            ORDER BY client_order_positions.created_at DESC 
            LIMIT 1) AS latest_client_order_price"
        )
    
      render json: @parts.map { |part|
        part.attributes.merge(
          current_quantity: part.attributes['quantity'],
          latest_client_order_price: part.attributes['latest_client_order_price']
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
    def archive_client_order
      @client_order = ClientOrderPosition.find_by(id: params[:client_order_id])
    
      if @client_order
        @client_order.update!(archived: true)
      
        render json: { success: "Client order #{@client_order} deleted successfully" }, status: :ok
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

    def archive_supplier_order
      @supplier_order = SupplierOrderPosition.find_by(id: params[:supplier_order_id])
    
      if @supplier_order
        @supplier_order.update!(archived: true)
        render json: { success: "Supplier order #{@supplier_order} deleted successfully" }, status: :ok
      else
        render json: { error: "Supplier order not found" }, status: :not_found
      end
    end

    def archive_expedition_position
      expedition_position = ExpeditionPosition.find_by(id: params[:expedition_position_id])
    
      return render json: { error: "Expedition position not found" }, status: :not_found unless expedition_position
    
      ActiveRecord::Base.transaction do
        expedition_position.update!(archived: true)

        render json: { success: "Expedition position archived successfully" }, status: :ok
      rescue StandardError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end
    end

    def archive_client_position
      client_position = ClientPosition.find_by(id: params[:client_position_id])
    
      return render json: { error: "Client position not found" }, status: :not_found unless client_position
    
      ActiveRecord::Base.transaction do
        client_position.update!(archived: true)
    
        render json: { success: "Client position archived successfully" }, status: :ok
      rescue StandardError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end
    end
  
    private

    def fetch_transit_methods(order_slip)
      methods = []
      methods << "Boat" if order_slip.is_boat
      methods << "Flight" if order_slip.is_flight
      methods << "Train" if order_slip.is_train
      methods.any? ? methods.join(", ") : "Not specified"
    end

    def resolve_destination_name(destination_type, logistic_place_id, subcontractor_id, destination_name)
      case destination_type
      when "subcontractor"
        subcontractor = SubContractor.find_by(id: subcontractor_id)
        return subcontractor&.name
      when "logistic_place"
        logistic_place = LogisticPlace.find_by(id: logistic_place_id)
        return logistic_place&.name
      when "client"
        return destination_name
      else
        nil
      end
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

    def calculate_available_stock(part_id)
      stock_service = StockService.new
      stock_service.calculate_available_stock(part_id)
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
      params.require(:supplier_order).permit(:number, :price, :quantity_status, :emission_date, :supplier_contact, :order_date, :order_delivery_time, :estimated_delivery_time, :estimated_departure_time, :supplier_id, :quantity, :transporter, :company_id, :part_id, 
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
      params.require(:expedition).permit(:real_departure_time, :price, :number, :estimated_departure_time, :estimated_arrival_time, :arrival_time)
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
  