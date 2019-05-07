class UserFlight < ApplicationRecord
  belongs_to :user
  belongs_to :outbound_flight, class_name: "Flight", optional: true
  belongs_to :inbound_flight, class_name: "Flight", optional: true
end
