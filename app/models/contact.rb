class Contact < ApplicationRecord
  belongs_to :contactable, polymorphic: true

  has_many :client_orders
  has_many :supplier_orders
end
