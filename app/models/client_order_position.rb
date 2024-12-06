class ClientOrderPosition < ApplicationRecord
  belongs_to :client_order
  belongs_to :part
end
