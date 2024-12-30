class Client < ApplicationRecord
  belongs_to :user

  has_many :contacts, as: :contactable, dependent: :destroy
  has_many :standard_stocks, dependent: :destroy
  has_many :consignment_stocks, dependent: :destroy
  has_many :client_positions, dependent: :destroy
  has_many :client_orders, dependent: :destroy
  has_many :parts, dependent: :destroy
  
  has_and_belongs_to_many :expedition_positions

  accepts_nested_attributes_for :contacts, :consignment_stocks, :standard_stocks
end
