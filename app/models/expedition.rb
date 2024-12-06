class Expedition < ApplicationRecord
    belongs_to :supplier

    has_many :expedition_positions, dependent: :destroy
    has_many :client_positions
    has_and_belongs_to_many :supplier_orders
    has_and_belongs_to_many :supplier_order_indices
end
