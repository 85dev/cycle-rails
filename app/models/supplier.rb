class Supplier < ApplicationRecord
  belongs_to :company

  has_many :contacts, as: :contactable
  has_many :expeditions
  has_many :supplier_orders
  has_and_belongs_to_many :parts
end
