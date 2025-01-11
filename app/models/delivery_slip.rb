class DeliverySlip < ApplicationRecord
    belongs_to :client_order
    belongs_to :part
    belongs_to :company
    belongs_to :expedition_position
    belongs_to :contact
    belongs_to :logistic_place, optional: true
    belongs_to :sub_contractor, optional: true
    belongs_to :client, optional: true
end
