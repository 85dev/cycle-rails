class ConsignmentStockPart < ApplicationRecord
    belongs_to :consignment_stock
    belongs_to :part

    validates :current_quantity, numericality: { greater_than_or_equal_to: 0 }
end