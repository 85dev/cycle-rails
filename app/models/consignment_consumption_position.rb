class ConsignmentConsumptionPosition < ApplicationRecord
    belongs_to :consignment_consumption
    belongs_to :part
end