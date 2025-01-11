class PdfGeneratorController < ApplicationController
    def create_delivery_slip
      company = Company.find_by(id: params[:company_id])
      expedition_position = ExpeditionPosition.find_by(id: params[:expedition_position_id])
      client_order = ClientOrder.find_by(id: params[:client_order_id])
      contact = Contact.find_by(id: params[:contact_id])

      transfer_quantity = params[:quantity].to_i
      delivery_slip_number = params[:delivery_slip]
      transfer_date = params[:transfer_date] || Date.today
      departure_address = params[:departure_address]
      arrival_address = params[:arrival_address]
      packaging_informations = params[:packaging_informations]
      transport_conditions = params[:transport_conditions]
      brut_weight = params[:brut_weight]
      net_weight = params[:net_weight]

      # Create DeliverySlip model
      delivery_slip = DeliverySlip.create!(
        expedition_position: expedition_position,
        part: expedition_position.part,
        company: company,
        contact: contact,
        client_order: client_order,
        transfer_date: transfer_date,
        number: delivery_slip_number,
        packaging_informations: params[:packaging_informations],
        transport_conditions: params[:transport_conditions],
        brut_weight: params[:brut_weight],
        net_weight: params[:net_weight],
        departure_address: departure_address,
        arrival_address: arrival_address
      )
  
      render json: { delivery_slip_id: delivery_slip.id }, status: :ok
    end

    def fetch_last_delivery_slip_by_client
      client_id = params[:client_id]
      client = Client.find_by(id: client_id)
    
      return render json: { error: "Client not found" }, status: :not_found unless client
    
      # Fetch delivery slips associated with the client through client orders
      last_delivery_slip = DeliverySlip
                             .joins(:client_order)
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
    
      # Company Name at the top-center
      pdf.text delivery_slip.company.name, size: 18, style: :bold, align: :center
      pdf.move_down 150

      pdf.bounding_box([0, pdf.cursor], width: pdf.bounds.width) do
        # Delivery Number on the left
        pdf.bounding_box([0, pdf.cursor], width: pdf.bounds.width / 2) do
          pdf.text "Delivery note : #{delivery_slip.number}", size: 12, style: :bold, align: :left
        end
      
        # Transfer Date on the right
        pdf.bounding_box([pdf.bounds.width / 2, pdf.cursor + 16], width: pdf.bounds.width / 2) do
          pdf.text "Date : #{delivery_slip.transfer_date.strftime('%d/%m/%Y')}", size: 12, style: :bold, align: :right
        end
      end
      pdf.move_down 20

      pdf.text "Contact : #{delivery_slip.contact&.first_name} #{delivery_slip.contact&.last_name}"
      pdf.text "Company : #{delivery_slip.client_order.client&.name}"
      pdf.move_down 20
      # Addresses
      pdf.bounding_box([0, pdf.cursor], width: pdf.bounds.width) do
        # Departure Address on the left
        pdf.bounding_box([0, pdf.cursor], width: pdf.bounds.width / 2) do
          pdf.text "Departure Address:", style: :bold
          pdf.text delivery_slip.departure_address
        end
    
        # Arrival Address on the right
        pdf.bounding_box([pdf.bounds.width - 200, pdf.cursor + 28], width: pdf.bounds.width / 2) do
          pdf.text "Delivery Address:", style: :bold
          pdf.text delivery_slip.arrival_address
        end
      end
      pdf.move_down 30
    
      # Table for Expedition Position
      pdf.text "Contenu de l'expédition :", size: 12, style: :italic, align: :left
      pdf.move_down 20
      table_data = [
        ["Reference", "Designation", "Quantity"],
        [delivery_slip.part.reference, delivery_slip.part.designation, delivery_slip.expedition_position.quantity]
      ]
      pdf.table(table_data, column_widths: [180, 180, 180], position: :left, row_colors: ["F0F0F0", "FFFFFF"], header: true)
      pdf.move_down 20
    
      pdf.bounding_box([0, pdf.cursor], width: pdf.bounds.width) do
        # Gross Weight
        pdf.bounding_box([0, pdf.cursor], width: pdf.bounds.width / 3) do
          pdf.text "Gross Weight:", style: :bold
          pdf.text delivery_slip.brut_weight.to_s + "kg(s)"
        end
      
        # Packaging Info
        pdf.bounding_box([pdf.bounds.width - 200, pdf.cursor + 28], width: pdf.bounds.width / 3) do
          pdf.text "Packaging Info:", style: :bold
          pdf.text delivery_slip.packaging_informations
        end
      end
      pdf.move_down 20

      pdf.text "Transport Conditions:", style: :bold
      pdf.text delivery_slip.transport_conditions
    
      # Page footer
      pdf.number_pages "<page>/<total>", align: :right, start_count_at: 1, at: [pdf.bounds.right - 50, 0]
    
      send_data(pdf.render, filename: "DeliverySlip_#{delivery_slip.number}.pdf", type: "application/pdf", disposition: "inline")
    end
  end