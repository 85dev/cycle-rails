class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :jwt_authenticatable,
         jwt_revocation_strategy: JwtDenylist

  has_many :clients
  has_many :parts
  has_many :logistic_places
  has_many :suppliers
end