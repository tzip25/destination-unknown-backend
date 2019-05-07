class AddRoundtripToUserFlights < ActiveRecord::Migration[5.2]
  def change
    add_column :user_flights, :outbound_flight_id, :integer
    add_column :user_flights, :inbound_flight_id, :integer
    remove_column :user_flights, :flight_id, :integer
  end
end
