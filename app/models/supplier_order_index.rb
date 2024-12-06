class SupplierOrderIndex < ApplicationRecord
  belongs_to :supplier_order_position
  belongs_to :part
  
  has_many :expedition_positions, dependent: :destroy
  has_many :client_positions
  has_and_belongs_to_many :expeditions
end
