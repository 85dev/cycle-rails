class Company < ApplicationRecord
    has_many :accounts, dependent: :destroy
    has_many :parts, dependent: :destroy
    has_many :clients, dependent: :destroy
    has_many :suppliers, dependent: :destroy
    has_many :sub_contractors, dependent: :destroy
    has_many :logistic_places, dependent: :destroy
    has_many :transporters, dependent: :destroy

    # Through :models relationships
    has_many :client_orders, through: :clients
    has_many :supplier_orders, through: :suppliers
    has_many :expeditions, through: :suppliers
    has_many :users, through: :accounts

    validates :name, presence: true
end
