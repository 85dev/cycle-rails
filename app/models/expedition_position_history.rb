class ExpeditionPositionHistory < ApplicationRecord
    belongs_to :expedition_position
    belongs_to :part
end