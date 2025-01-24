class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :jwt_authenticatable, :recoverable,
         jwt_revocation_strategy: JwtDenylist

  has_many :accounts, dependent: :destroy
  has_many :companies, through: :accounts
end