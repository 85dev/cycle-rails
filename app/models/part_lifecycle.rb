class PartLifecycle < ApplicationRecord
    belongs_to :part
    belongs_to :entity, polymorphic: true
  
    validates :step_name, presence: true
    validates :sequence_order, presence: true
end