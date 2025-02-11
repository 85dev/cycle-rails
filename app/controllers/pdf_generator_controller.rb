class PdfGeneratorController < ApplicationController
    def create_delivery_slip
      company = Company.find_by(id: params[:company_id])
      client_order = ClientOrder.find_by(id: params[:client_order_id])
      contact = Contact.find_by(id: params[:contact_id])

      # For multiple associations purposes
      expedition_position_ids = params[:expedition_position_ids]
      client_order_ids = params[:client_order_ids]

      quantity = params[:quantity].to_i
      delivery_slip_number = params[:delivery_slip]
      transfer_date = params[:transfer_date]
      departure_address = params[:departure_address]
      arrival_address = params[:arrival_address]
      packaging_informations = params[:packaging_informations]
      transport_conditions = params[:transport_conditions]
      brut_weight = params[:brut_weight]
      net_weight = params[:net_weight]

      # Create DeliverySlip model
      delivery_slip = DeliverySlip.create!(
        company: company,
        contact: contact,
        transfer_date: transfer_date,
        number: delivery_slip_number,
        packaging_informations: params[:packaging_informations],
        transport_conditions: params[:transport_conditions],
        brut_weight: params[:brut_weight],
        net_weight: params[:net_weight],
        departure_address: departure_address,
        arrival_address: arrival_address
      )

      if expedition_position_ids.present?
        expedition_positions = ExpeditionPosition.where(id: expedition_position_ids)
        delivery_slip.expedition_positions << expedition_positions
      end

      if client_order_ids.present?
        client_orders = ClientOrder.where(id: client_order_ids)
        delivery_slip.client_orders << client_orders
      end
  
      render json: { delivery_slip_id: delivery_slip.id }, status: :ok
    end

    def fetch_last_delivery_slip_by_client
      client_id = params[:client_id]
      client = Client.find_by(id: client_id)
    
      return render json: { error: "Client not found" }, status: :not_found unless client
    
      # Fetch delivery slips associated with the client through client orders
      last_delivery_slip = DeliverySlip
                             .joins(:client_orders)
                             .where(client_orders: { client_id: client_id })
                             .order(created_at: :desc)
                             .first
    
      if last_delivery_slip
        render json: {
          success: "Last delivery slip retrieved successfully",
          delivery_slip: last_delivery_slip
        }, status: :ok
      else
        render json: { error: "No delivery slips found for the client" }, status: :not_found
      end
    end

    def generate_delivery_slip_pdf
      delivery_slip = DeliverySlip.find_by(id: params[:delivery_slip_id])
      return render json: { error: "Delivery slip not found" }, status: :not_found unless delivery_slip
    
      pdf = Prawn::Document.new
    
      pdf.text delivery_slip.company.name, size: 18, style: :bold, align: :center
      pdf.move_down 120

      pdf.bounding_box([0, pdf.cursor], width: pdf.bounds.width) do
        pdf.bounding_box([0, pdf.cursor], width: pdf.bounds.width / 2) do
          pdf.text "Delivery note : #{delivery_slip.number}", size: 12, style: :bold, align: :left
        end
      
        pdf.bounding_box([pdf.bounds.width / 2, pdf.cursor + 16], width: pdf.bounds.width / 2) do
          pdf.text "Date : #{delivery_slip.transfer_date.strftime('%d/%m/%Y')}", size: 12, style: :bold, align: :right
        end
      end
      pdf.move_down 20

      pdf.text "Contact : #{delivery_slip.contact&.first_name} #{delivery_slip.contact&.last_name}"
      pdf.text "Company : #{delivery_slip.client_orders[0].client&.name}"
      client_order_numbers = delivery_slip.client_orders.map(&:number).join(", ")
      pdf.text "Client Order(s): #{client_order_numbers}" unless client_order_numbers.empty?

      pdf.move_down 20
      pdf.text "Delivery Address:", style: :bold
      pdf.text delivery_slip.arrival_address

      pdf.move_down 10
      pdf.text "Departure Address:", style: :bold
      pdf.text delivery_slip.departure_address
      pdf.move_down 30
    
      pdf.text "Transport positions :", size: 12, align: :left
      pdf.move_down 5
      table_data = [["Reference", "Designation", "Quantity"]]
      delivery_slip.expedition_positions.each do |position|
        table_data << [
          position.part&.reference || "N/A",
          position.part&.designation || "N/A",
          position.quantity
        ]
      end
      pdf.table(table_data, column_widths: [180, 180, 180], position: :left, row_colors: ["F0F0F0", "FFFFFF"], header: true)
      pdf.move_down 20
    
      pdf.bounding_box([0, pdf.cursor], width: pdf.bounds.width) do
        pdf.bounding_box([0, pdf.cursor], width: pdf.bounds.width / 3) do
          pdf.text "Gross Weight:", style: :bold
          pdf.text delivery_slip.brut_weight.to_s + "kg(s)"
        end
      
        pdf.bounding_box([pdf.bounds.width - 200, pdf.cursor + 28], width: pdf.bounds.width / 3) do
          pdf.text "Packaging Info:", style: :bold
          pdf.text delivery_slip.packaging_informations
        end
      end
      pdf.move_down 30

      pdf.text "Transport Conditions:", style: :bold
      pdf.text delivery_slip.transport_conditions
    
      pdf.number_pages "<page>/<total>", align: :right, start_count_at: 1, at: [pdf.bounds.right - 50, 0]
    
      send_data(pdf.render, filename: "DeliverySlip_#{delivery_slip.number}.pdf", type: "application/pdf", disposition: "inline")
    end

    def order_slip_single_position
      order_slip = OrderSlip.create!(
        company_id: params[:company_id],
        supplier_order_position_id: params[:supplier_order_position_id],
        supplier_order_id: params[:supplier_order_id],
        contact_id: params[:contact_id],
        is_boat: params[:is_boat] || false,
        is_flight: params[:is_flight] || false,
        is_train: params[:is_train] || false,
        transporter_id: params[:transporter_id],
        informations: params[:informations]
      )
  
      render json: { id: order_slip.id, message: "Order Slip Created" }, status: :ok
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

    def generate_order_slip_single_position_pdf
      order_slip = OrderSlip.find_by(id: params[:order_slip_id])
      return render json: { error: "Order slip not found" }, status: :not_found unless order_slip
    
      supplier_order_position = order_slip.supplier_order_position
      return render json: { error: "Supplier order position not found" }, status: :not_found unless supplier_order_position
    
      supplier_order = order_slip.supplier_order
      return render json: { error: "Supplier order not found" }, status: :not_found unless supplier_order
    
      contact = order_slip.contact
      transporter = order_slip.transporter
      company = supplier_order.supplier.company

      pdf = Prawn::Document.new

      pdf.text company.name, size: 18, align: :center
      pdf.move_down 50
    
      pdf.text "Purchase Order Number: #{supplier_order.number}", size: 12, style: :bold
      pdf.move_down 10
      
      pdf.text "To: #{supplier_order.supplier.name}", size: 12
      pdf.text "Contact: #{contact&.first_name} #{contact&.last_name}" if contact.present?
      pdf.text "Order Date: #{supplier_order.emission_date.strftime('%d/%m/%Y')}", size: 12
      pdf.move_down 20
    
      transit_methods = []
      transit_methods << "Boat" if order_slip.is_boat
      transit_methods << "Flight" if order_slip.is_flight
      transit_methods << "Train" if order_slip.is_train
      transit_methods_display = transit_methods.any? ? transit_methods.join(", ") : "Not specified"
    
      pdf.text "Transport Method: #{transit_methods_display}", size: 12
      pdf.text "Transporter: #{transporter&.name}" if transporter.present?
      pdf.move_down 20
    
      pdf.text "Position Details:", size: 12, style: :bold
      pdf.move_down 5
      table_data = [["Reference", "Description", "Quantity", "Price", "Total", "Delivery Date"]]
    
      amount = supplier_order_position.quantity.to_i * supplier_order_position.price.to_f
      table_data << [
        supplier_order_position.part.reference,
        supplier_order_position.part.designation,
        supplier_order_position.quantity,
        format('%.2f', supplier_order_position.price),
        format('%.2f', amount),
        supplier_order_position.delivery_date.strftime('%d/%m/%Y')
      ]
    
      pdf.table(table_data, column_widths: [100, 100, 80, 80, 80, 100], position: :center, row_colors: ["F0F0F0", "FFFFFF"], header: true)
      pdf.move_down 10
      pdf.text "Informations: #{order_slip.informations}" if order_slip.informations.present?
      pdf.move_down 30
    
      pdf.text "Total Amount: #{format('%.2f', amount)} €", size: 12, style: :bold
      pdf.move_down 20

      pdf.text "Legal Notice:", size: 12
      pdf.text company.legal_notice if company.legal_notice.present?
      pdf.move_down 10

      pdf.text "Authorized Signatory: #{company.authorized_signatory}", size: 12 if company.authorized_signatory.present?
    
      pdf.bounding_box([0, 50], width: pdf.bounds.width) do
        pdf.text "#{company.legal_structure}, #{company.name}", size: 12, align: :center
        pdf.text "#{company.address}", size: 12, align: :center
        pdf.text "Tax ID: #{company.tax_id}", size: 10, align: :center if company.tax_id.present?
        pdf.text "Reg. Number: #{company.registration_number}", size: 10, align: :center if company.registration_number.present?
        pdf.text "Website: #{company.website}" if company.website.present?
      end
      pdf.number_pages "<page>/<total>", align: :right, start_count_at: 1, at: [pdf.bounds.right - 50, 0]
      send_data(pdf.render, filename: "OrderSlip_#{supplier_order.number}.pdf", type: "application/pdf", disposition: "inline")
    end
  end