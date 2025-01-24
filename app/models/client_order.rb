class ClientOrder < ApplicationRecord
  belongs_to :client
  belongs_to :contact, optional: true
  
  has_many :client_order_positions, dependent: :destroy
  has_and_belongs_to_many :supplier_order_positions
  has_and_belongs_to_many :parts
  has_and_belongs_to_many :supplier_orders
  has_and_belongs_to_many :delivery_slips
end
