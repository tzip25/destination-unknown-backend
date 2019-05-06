class User < ApplicationRecord
  has_many :user_flights
  has_many :flights, through: :user_flights

  validates :username, uniqueness: true

  has_secure_password
end
