class SupplierOrderIndex < ApplicationRecord
  belongs_to :supplier_order_position
  belongs_to :part
  belongs_to :expedition

  has_many :client_positions
  has_and_belongs_to_many :expeditions
end
