class SubContractor < ApplicationRecord
  belongs_to :user
  
  has_and_belongs_to_many :expedition_positions
  has_and_belongs_to_many :parts
  has_and_belongs_to_many :supplier_orders, join_table: "sub_contractors_supplier_orders"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end