class OrderSlip < ApplicationRecord
  belongs_to :supplier_order_position, optional: true
  belongs_to :supplier_order, optional: true
  belongs_to :contact, optional: true
  belongs_to :transporter, optional: true
end
