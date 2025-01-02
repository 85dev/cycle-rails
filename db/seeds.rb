require 'faker'

# Assuming you already have a user in the database with the given email
user = User.find_by(email: 'mercier.ncls@gmail.com')

# Clean non-necessary data
Client.destroy_all
Supplier.destroy_all
Part.destroy_all
SubContractor.destroy_all
SupplierOrder.destroy_all
ClientOrder.destroy_all
LogisticPlace.destroy_all
# This script seeds the database with data: 3 clients, 3 transporters, 
# 3 subcontractors, 3 suppliers, 3 logistic places, and 5 parts for each client.

# Create a company (as all records belong to a company)
company = Company.create!(
    name: "Test Company",
    legal_structure: "LLC",
    address: "123 Main St",
    country: "USA",
    tax_id: "123-456-789",
    registration_number: "987654321",
    website: "https://testcompany.com"
  )
  
  # Create clients
  clients = [
    { name: "Client A", address: "123 Client St", country: "USA", contact_name: "Alice", contact_email: "alice@clienta.com" },
    { name: "Client B", address: "456 Client Ave", country: "Canada", contact_name: "Bob", contact_email: "bob@clientb.com" },
    { name: "Client C", address: "789 Client Blvd", country: "UK", contact_name: "Charlie", contact_email: "charlie@clientc.com" }
  ].map do |client_attrs|
    Client.create!(client_attrs.merge(company_id: company.id))
  end
  
  # Create transporters
  transporters = [
    { name: "Transporter X", transport_type: "Air" },
    { name: "Transporter Y", transport_type: "Sea" },
    { name: "Transporter Z", transport_type: "Land" }
  ].map do |transporter_attrs|
    Transporter.create!(transporter_attrs.merge(company_id: company.id))
  end
  
  # Create subcontractors
  subcontractors = [
    { name: "Subcontractor A", address: "123 Sub St", country: "USA", knowledge: "Machining", contact_name: "Sub Alice", contact_email: "subalice@suba.com" },
    { name: "Subcontractor B", address: "456 Sub Ave", country: "Canada", knowledge: "Welding", contact_name: "Sub Bob", contact_email: "subbob@subb.com" },
    { name: "Subcontractor C", address: "789 Sub Blvd", country: "UK", knowledge: "Painting", contact_name: "Sub Charlie", contact_email: "subcharlie@subc.com" }
  ].map do |subcontractor_attrs|
    SubContractor.create!(subcontractor_attrs.merge(company_id: company.id))
  end
  
  # Create suppliers
  suppliers = [
    { name: "Supplier A", address: "123 Supplier St", country: "USA", knowledge: "Steel", contact_name: "Supplier Alice", contact_email: "supalice@suppa.com" },
    { name: "Supplier B", address: "456 Supplier Ave", country: "Canada", knowledge: "Aluminum", contact_name: "Supplier Bob", contact_email: "supbob@suppb.com" },
    { name: "Supplier C", address: "789 Supplier Blvd", country: "UK", knowledge: "Plastic", contact_name: "Supplier Charlie", contact_email: "supcharlie@suppc.com" }
  ].map do |supplier_attrs|
    Supplier.create!(supplier_attrs.merge(company_id: company.id))
  end
  
  # Create logistic places
  logistic_places = [
    { name: "Logistic Place A", address: "123 Logistic St", contact_name: "Logistic Alice", contact_email: "logalice@logistica.com" },
    { name: "Logistic Place B", address: "456 Logistic Ave", contact_name: "Logistic Bob", contact_email: "logbob@logisticb.com" },
    { name: "Logistic Place C", address: "789 Logistic Blvd", contact_name: "Logistic Charlie", contact_email: "logcharlie@logisticc.com" }
  ].map do |logistic_place_attrs|
    LogisticPlace.create!(logistic_place_attrs.merge(company_id: company.id))
  end
  
  # Create parts for each client
  clients.each do |client|
    5.times do |i|
      Part.create!(
        designation: "Part #{i + 1} for #{client.name}",
        reference: "REF#{client.id}-#{i + 1}",
        material: %w[Steel Aluminum Plastic].sample,
        drawing: "DRAW#{client.id}-#{i + 1}",
        weight: rand(10.0..50.0).round(2),
        client_id: client.id,
        company_id: company.id,
        price: rand(100..500)
      )
    end
  end
  
puts "Seeding completed successfully!"
