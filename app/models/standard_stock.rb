class StandardStock < ApplicationRecord
    belongs_to :client
    has_and_belongs_to_many :client_positions
  end