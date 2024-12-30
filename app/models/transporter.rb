class Transporter < ApplicationRecord
  belongs_to :user

  has_many :contacts, as: :contactable, dependent: :destroy
end
