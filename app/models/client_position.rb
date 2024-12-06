class ClientPosition < ApplicationRecord
  belongs_to :client
  belongs_to :part
  belongs_to :expedition
  belongs_to :supplier_order_index, optional: true

  has_and_belongs_to_many :standard_stocks
  has_and_belongs_to_many :consignment_stocks
  validates :quantity, numericality: { greater_than_or_equal_to: 0 }
end
