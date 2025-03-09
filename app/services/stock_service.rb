class StockService
    def initialize(company: nil, part: nil)
      @company = company
      @part = part
      @part_id = part&.id
    end
  
    def fetch_calculate_part_stocks
      return unless @part
    
      current_stock = calculate_current_stock(@part_id) # No more standard stock
      reserved_stock = calculate_reserved_stock(@part_id)
      ordered_stock = calculate_ordered_supplier_orders(@part_id)
      in_transit_stock = calculate_in_transit_expeditions(@part_id)
      supplier_ids = @part.suppliers.pluck(:id)
    
      # Compute final stock values without standard stock
      total_current_stock = current_stock[:total]
      total_available_stock = total_current_stock - reserved_stock
      total_future_stock = total_available_stock + ordered_stock + in_transit_stock
    
      {
        current_stock: {
          consignment_stock: current_stock[:consignment],
          subcontractor_stock: current_stock[:subcontractor],
          logistic_place_stock: current_stock[:logistic_place],
          total: total_current_stock
        },
        ordered_stock: {
          supplier_orders: ordered_stock,
          expeditions: in_transit_stock
        },
        reserved_stock: reserved_stock,
        total_current_stock: total_current_stock,
        total_available_stock: total_available_stock,
        total_future_stock: total_future_stock,
        supplier_ids: supplier_ids
      }
    end
  
    def fetch_all_parts_stocks
      return [] unless @company
    
      parts = Part.includes(:suppliers).where(company_id: @company.id)
      part_ids = parts.pluck(:id)
    
      consignment_stocks = calculate_consignment_stock(part_ids)
      subcontractor_stocks = calculate_subcontractor_stock(part_ids)
      logistic_place_stocks = calculate_logistic_place_stock(part_ids)
      ordered_supplier_orders = calculate_ordered_supplier_orders(part_ids, group: true)
      reserved_client_orders = calculate_reserved_stock(part_ids, group: true)
      in_transit_expeditions = calculate_in_transit_expeditions(part_ids, group: true)
    
      client_names = Client.joins(client_positions: :part)
                           .where(client_positions: { part_id: part_ids })
                           .pluck('client_positions.part_id', 'clients.name')
                           .to_h
     
      parts.map do |part|
        part_id = part.id
        consignment_stock = consignment_stocks[part_id] || 0
        subcontractor_stock = subcontractor_stocks[part_id] || 0
        logistic_place_stock = logistic_place_stocks[part_id] || 0
        reserved_stock = reserved_client_orders[part_id] || 0
    
        total_current_stock = consignment_stock + subcontractor_stock + logistic_place_stock
        total_available_stock = total_current_stock - reserved_stock
        total_future_stock = total_available_stock + (ordered_supplier_orders[part_id] || 0) + (in_transit_expeditions[part_id] || 0)
    
        {
          id: part_id,
          client_name: client_names[part_id],
          reference_and_designation: "#{part.reference} #{part.designation}",
          consignment_stock: consignment_stock,
          subcontractor_stock: subcontractor_stock,
          logistic_place_stock: logistic_place_stock,
          total_current_stock: total_current_stock,
          reserved_stock: reserved_stock,
          total_available_stock: total_available_stock,
          total_future_stock: total_future_stock,
          supplier_orders: ordered_supplier_orders[part_id] || 0,
          expeditions: in_transit_expeditions[part_id] || 0,
          supplier_ids: part.suppliers.pluck(:id) # Fetch supplier IDs
        }
      end
    end
  
    def calculate_available_stock(part_id)
      calculate_current_stock(part_id)[:total]
    end
  
    private
  
    def calculate_current_stock(part_id)
      consignment = ConsignmentStockPart.where(part_id: part_id).sum(:current_quantity)
      subcontractor = ExpeditionPosition.joins(:sub_contractors)
                                        .where(part_id: part_id, archived: false)
                                        .sum(:quantity)
      logistic_place = ExpeditionPosition.joins(:logistic_places)
                                         .where(part_id: part_id, archived: false)
                                         .sum(:quantity)
  
      {
        consignment: consignment,
        subcontractor: subcontractor,
        logistic_place: logistic_place,
        total: consignment + subcontractor + logistic_place # Standard stock removed
      }
    end
  
    def calculate_reserved_stock(part_ids, group: false)
      query = ClientOrderPosition.joins(:client_order)
                                 .where(client_orders: { order_status: 'undelivered' })
                                 .where(part_id: part_ids)
                                 .where(archived: false)
  
      group ? query.group(:part_id).sum(:quantity) : query.sum(:quantity)
    end
  
  
    def calculate_ordered_supplier_orders(part_ids, group: false)
      query = SupplierOrderPosition.where(part_id: part_ids, archived: false)
                                   .where.not(status: 'completed')
  
      if group
        query = query.group(:part_id)
                     .select("part_id, 
                              SUM(quantity - COALESCE(partial_quantity_delivered, 0) - COALESCE(real_quantity_delivered, 0)) AS remaining_quantity")
                     .index_by(&:part_id)
                     .transform_values { |record| record.remaining_quantity.to_i }
      else
        query.sum("quantity - COALESCE(partial_quantity_delivered, 0) - COALESCE(real_quantity_delivered, 0)")
      end
    end
  
    def calculate_in_transit_expeditions(part_ids, group: false)
      query = SupplierOrderIndex.joins(:supplier_order_position)
                                .joins(:expedition)
                                .where(supplier_order_positions: { part_id: part_ids })
                                .where(expeditions: { status: ['undelivered', 'in_transit'] })
  
      group ? query.group(:part_id).sum(:quantity) : query.sum(:quantity)
    end
  
    def calculate_consignment_stock(part_ids)
      ConsignmentStockPart.where(part_id: part_ids)
                          .group(:part_id)
                          .sum(:current_quantity)
    end
  
    def calculate_subcontractor_stock(part_ids)
      ExpeditionPosition.joins(:sub_contractors)
                        .where(part_id: part_ids, archived: false)
                        .group(:part_id)
                        .sum(:quantity)
    end
  
    def calculate_logistic_place_stock(part_ids)
      ExpeditionPosition.joins(:logistic_places)
                        .where(part_id: part_ids, archived: false)
                        .group(:part_id)
                        .sum(:quantity)
    end
  end