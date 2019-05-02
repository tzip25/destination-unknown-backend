class Flight < ApplicationRecord
  # belongs_to :start_location, class_name: "Location", foreign_key: "start_location_id"
  # belongs_to :end_location, class_name: "Location", foreign_key: "end_location_id"
  
  has_many :user_flights
  has_many :users, through: :user_flights
end
