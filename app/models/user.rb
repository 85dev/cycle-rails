class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :jwt_authenticatable,
         jwt_revocation_strategy: JwtDenylist

  has_many :accounts, dependent: :destroy
  has_many :companies, through: :accounts
end