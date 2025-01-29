class ExpeditionPositionHistory < ApplicationRecord
    belongs_to :expedition_position, optional: true
    belongs_to :client_position, optional: true
    belongs_to :part

    has_many :history_steps
end