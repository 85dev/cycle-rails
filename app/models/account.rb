class Account < ApplicationRecord
    belongs_to :user
    belongs_to :company
  
    validates :status, inclusion: { in: %w[pending accepted rejected] }
    validates_uniqueness_of :user_id, scope: :company_id
end
