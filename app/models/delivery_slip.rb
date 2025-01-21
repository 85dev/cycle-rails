class DeliverySlip < ApplicationRecord
    belongs_to :client_order
    belongs_to :part
    belongs_to :company
    belongs_to :contact
    belongs_to :logistic_place, optional: true
    belongs_to :sub_contractor, optional: true
    belongs_to :client, optional: true

    has_and_belongs_to_many :expedition_positions
end
