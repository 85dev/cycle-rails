class ConsignmentConsumption < ApplicationRecord
    belongs_to :consignment_stock

    has_many :consignment_consumption_positions, dependent: :destroy
end