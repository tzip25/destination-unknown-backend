class Location < ApplicationRecord
  has_many :start_locations, through: :flights
  has_many :flights, class_name: "Flight", foreign_key: "start_location_id", dependent: :destroy

  has_many :end_locations, through: :flights
  has_many :flights, class_name: "Flight", foreign_key: "end_location_id", dependent: :destroy

end
