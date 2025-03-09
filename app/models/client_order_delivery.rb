class ClientOrderDelivery < ApplicationRecord
   belongs_to :part
   belongs_to :client_order_position

   has_one :client_order, through: :client_order_position
end