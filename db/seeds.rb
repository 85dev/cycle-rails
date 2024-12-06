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

# Create Clients
client1 = Client.create(name: "Client A", user_id: user.id, address: Faker::Address.street_address, country: Faker::Address.country)
client2 = Client.create(name: "Client B", user_id: user.id, address: Faker::Address.street_address, country: Faker::Address.country)

# Create Suppliers
supplier1 = Supplier.create(name: "Supplier A", knowledge: "Expert in Iron", user_id: user.id, address: Faker::Address.street_address, country: Faker::Address.country)
supplier2 = Supplier.create(name: "Supplier B", knowledge: "Expert in Steel", user_id: user.id, address: Faker::Address.street_address, country: Faker::Address.country)

# Create Parts
part1 = Part.create(designation: "Iron Bolt", reference: "IB001", material: "Iron", drawing: "Drawing A", user_id: user.id)
part2 = Part.create(designation: "Steel Nut", reference: "SN002", material: "Steel", drawing: "Drawing B", user_id: user.id)
part3 = Part.create(designation: "Aluminum Washer", reference: "AW003", material: "Aluminum", drawing: "Drawing C", user_id: user.id)

# Create Sub Contractors with supplier_order_id set to nil
sub_contractor1 = SubContractor.create(part_id: part1.id, user: user, name: "SubContractor A", address: Faker::Address.street_address, country: Faker::Address.country, knowledge: "Iron Welding")
sub_contractor2 = SubContractor.create(part_id: part2.id, user: user, name: "SubContractor B", address: Faker::Address.street_address, country: Faker::Address.country, knowledge: "Steel Welding")

# Create Supplier Orders and associate them with parts
supplier_order1 = SupplierOrder.create(supplier_id: supplier1.id, quantity: 100, previsionnal: false, transporter: "DHL", order_date: Time.now, delivery_status: true, batch: "Batch A")
supplier_order2 = SupplierOrder.create(supplier_id: supplier2.id, quantity: 200, previsionnal: true, transporter: "UPS", order_date: Time.now, delivery_status: false, batch: "Batch B")

# Many-to-Many: Linking Parts and SupplierOrders
SupplierOrdersPart.create(supplier_order_id: supplier_order1.id, part_id: part1.id)
SupplierOrdersPart.create(supplier_order_id: supplier_order1.id, part_id: part2.id)
SupplierOrdersPart.create(supplier_order_id: supplier_order2.id, part_id: part3.id)

# Create Client Orders
client_order1 = ClientOrder.create(client_id: client1.id, transporter: "FedEx", quantity: 50, order_status: true, order_date: Time.now, number: 1234, batch: "Batch 1234")
client_order2 = ClientOrder.create(client_id: client2.id, transporter: "TNT", quantity: 75, order_status: false, order_date: Time.now, number: 5678, batch: "Batch 5678")

# Many-to-Many: Linking Parts and ClientOrders
ClientOrdersPart.create(client_order_id: client_order1.id, part_id: part1.id)
ClientOrdersPart.create(client_order_id: client_order1.id, part_id: part2.id)
ClientOrdersPart.create(client_order_id: client_order2.id, part_id: part3.id)

# Create Logistic Places
logistic_place1 = LogisticPlace.create(user_id: user.id, address: Faker::Address.street_address)
logistic_place2 = LogisticPlace.create(user_id: user.id, address: Faker::Address.street_address)

# Many-to-Many: Linking Parts and LogisticPlaces
LogisticPlacesPart.create(logistic_place_id: logistic_place1.id, part_id: part1.id)
LogisticPlacesPart.create(logistic_place_id: logistic_place1.id, part_id: part2.id)
LogisticPlacesPart.create(logistic_place_id: logistic_place2.id, part_id: part3.id)

# Many-to-Many: Linking Supplier Orders and LogisticPlaces
LogisticPlacesSupplierOrder.create(logistic_place_id: logistic_place1.id, supplier_order_id: supplier_order1.id)
LogisticPlacesSupplierOrder.create(logistic_place_id: logistic_place2.id, supplier_order_id: supplier_order2.id)

# Many-to-Many: Linking SupplierOrders and SubContractors
SubContractorsSupplierOrder.create(sub_contractor_id: sub_contractor1.id, supplier_order_id: supplier_order1.id)
SubContractorsSupplierOrder.create(sub_contractor_id: sub_contractor2.id, supplier_order_id: supplier_order2.id)

puts "Seeding completed successfully!"
