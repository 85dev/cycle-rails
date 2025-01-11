class SupplierOrder < ApplicationRecord
  belongs_to :supplier
  belongs_to :contact, optional: true
  
  has_and_belongs_to_many :expeditions
  has_and_belongs_to_many :parts, join_table: :parts_supplier_orders
  has_and_belongs_to_many :sub_contractors
  has_and_belongs_to_many :logistic_places
  has_and_belongs_to_many :client_orders
  
  has_many :supplier_order_indexes
  has_many :supplier_order_positions, dependent: :destroy
  accepts_nested_attributes_for :supplier_order_positions
end
