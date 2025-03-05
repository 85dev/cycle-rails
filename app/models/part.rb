class Part < ApplicationRecord
  belongs_to :company
  belongs_to :client

  has_many :client_order_positions, dependent: :destroy
  has_many :supplier_order_indices, dependent: :destroy
  has_many :supplier_order_positions, dependent: :destroy
  has_many :client_positions, dependent: :destroy
  has_many :part_histories, dependent: :destroy
  has_many :consignment_stock_parts
  has_many :expedition_position_histories
  has_many :expedition_positions
  has_many :part_lifecycles, dependent: :destroy
  accepts_nested_attributes_for :part_lifecycles, allow_destroy: true

  has_and_belongs_to_many :suppliers
  has_and_belongs_to_many :supplier_orders
  has_and_belongs_to_many :client_orders
  has_and_belongs_to_many :sub_contractors
  has_and_belongs_to_many :logistic_places

  validates :reference, uniqueness: { scope: :designation, message: 'and designation combination must be unique' }
end
