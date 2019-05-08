class User < ApplicationRecord
  has_many :user_flights
  has_many :outbound_flights, through: :user_flights
  has_many :inbound_flights, through: :user_flights
  
  validates :username, uniqueness: true

  has_secure_password
end
