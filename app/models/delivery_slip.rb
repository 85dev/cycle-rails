class DeliverySlip < ApplicationRecord
    belongs_to :part, optional: true
    belongs_to :company
    belongs_to :contact
    belongs_to :logistic_place, optional: true
    belongs_to :sub_contractor, optional: true
    belongs_to :client, optional: true

    has_and_belongs_to_many :expedition_positions
    has_and_belongs_to_many :client_orders
end
