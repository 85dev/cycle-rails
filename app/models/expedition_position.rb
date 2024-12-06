class ExpeditionPosition < ApplicationRecord
    belongs_to :expedition
    belongs_to :supplier_order_index
    belongs_to :part

    has_and_belongs_to_many :logistic_places 
    has_and_belongs_to_many :sub_contractors
    has_and_belongs_to_many :clients
end
  