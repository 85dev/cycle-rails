class SupplierOrderPosition < ApplicationRecord
    belongs_to :supplier_order
    belongs_to :part

    has_and_belongs_to_many :client_orders
end