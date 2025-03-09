class ExpeditionDispatcherService
  def initialize(expedition, params)
    @expedition = expedition
    @supplier_order_indices_ids = params[:supplier_order_indices_ids]
    @subcontractors = params[:subcontractors]
    @logistic_places = params[:logistic_places]
    @references = params[:references]
    @designations = params[:designations]
    @clients = params[:clients]
    @clones = params[:clones]
    @quantities = params[:quantities]
    @arrival_time = params[:arrival_time]

    @part_cache = {}
  end

  def call
    ActiveRecord::Base.transaction do
      @supplier_order_indices_ids.each_with_index do |supplier_order_index_id, index|
        # Fetch SupplierOrderIndex
        supplier_order_index = SupplierOrderIndex.find_by(id: supplier_order_index_id)
        raise ActiveRecord::RecordNotFound, "SupplierOrderIndex not found: #{supplier_order_index_id}" unless supplier_order_index

        supplier_order_index.update!(status: 'delivered')
        supplier_order_position = supplier_order_index.supplier_order_position

        if supplier_order_position &&
           (supplier_order_index.quantity_status != 'partial' ||
            !%w[partial_sent_and_production production].include?(supplier_order_position.status))
          supplier_order_position.update!(real_delivery_date: @arrival_time)
        end    

        part_reference = @references[index]
        part_designation = @designations[index]
        part = @part_cache["#{part_reference}-#{part_designation}"] ||= Part.find_by(reference: part_reference, designation: part_designation)
        raise ActiveRecord::RecordNotFound, "Part not found: #{part_reference} - #{part_designation}" unless part

        client_name = @clients[index].presence
        if client_name
          client = Client.find_by(name: client_name)
          raise ActiveRecord::RecordNotFound, "Client not found: #{client_name}" unless client

          unless ClientPosition.exists?(
                   client_id: client.id,
                   supplier_order_index_id: supplier_order_index.id,
                   expedition_id: @expedition.id
                 )
            create_client_position(
              client_id: client.id,
              supplier_order_index_id: supplier_order_index.id,
              expedition_id: @expedition.id,
              part_id: part.id,
              quantity: @quantities[index],
              is_clone: @clones[index],
              sorted: false
            )
          end
        else
          subcontractor_name = @subcontractors[index].presence
          logistic_place_name = @logistic_places[index].presence

          position_params = {
            expedition_id: @expedition.id,
            supplier_order_index_id: supplier_order_index.id,
            supplier_order_position_id: supplier_order_position.id,
            part_id: part.id,
            quantity: @quantities[index],
            is_clone: @clones[index],
            finition_status: supplier_order_index.finition_status
          }

          if subcontractor_name
            subcontractor = SubContractor.find_by(name: subcontractor_name)
            raise ActiveRecord::RecordNotFound, "Subcontractor not found: #{subcontractor_name}" unless subcontractor

            position_params[:destination_type] = "subcontractor"
            position_params[:subcontractor_id] = subcontractor.id
          end

          if logistic_place_name
            logistic_place = LogisticPlace.find_by(name: logistic_place_name)
            raise ActiveRecord::RecordNotFound, "Logistic place not found: #{logistic_place_name}" unless logistic_place

            position_params[:destination_type] = "logistic_place"
            position_params[:logistic_place_id] = logistic_place.id
          end

          position = create_expedition_position(**position_params)

          position.logistic_places << logistic_place if logistic_place_name && !position.logistic_places.exists?(logistic_place.id)

          position.sub_contractors << subcontractor if subcontractor_name && !position.sub_contractors.exists?(subcontractor.id)
        end
      end

      # Update expedition status
      @expedition.update!(status: 'delivered', arrival_time: @arrival_time)

      { success: "Expedition dispatch completed successfully" }
    end
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound => e
    { error: e.message }
  end

  private

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

end