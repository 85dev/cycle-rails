class Part < ApplicationRecord
  belongs_to :user
  belongs_to :client

  has_many :client_order_positions, dependent: :destroy
  has_many :supplier_order_indices, dependent: :destroy
  has_many :supplier_order_positions, dependent: :destroy
  has_many :client_positions, dependent: :destroy
  has_many :part_histories, dependent: :destroy
  has_many :consignment_stock_parts

  has_and_belongs_to_many :suppliers
  has_and_belongs_to_many :supplier_orders
  has_and_belongs_to_many :client_orders
  has_and_belongs_to_many :sub_contractors
  has_and_belongs_to_many :logistic_places

  validates :reference, uniqueness: true, presence: true
  validates :designation, uniqueness: true, presence: true
end
