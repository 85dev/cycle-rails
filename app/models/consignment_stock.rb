class ConsignmentStock < ApplicationRecord
    belongs_to :client
    has_and_belongs_to_many :client_positions
    
    has_many :consignment_consumptions, dependent: :destroy
    has_many :consignment_stock_parts, dependent: :destroy
end