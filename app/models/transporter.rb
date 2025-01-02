class Transporter < ApplicationRecord
  belongs_to :company

  has_many :expeditions
  has_many :contacts, as: :contactable, dependent: :destroy
end
