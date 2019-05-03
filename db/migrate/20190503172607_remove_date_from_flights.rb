class RemoveDateFromFlights < ActiveRecord::Migration[5.2]
  def change
    remove_column :flights, :date, :date
    add_column :flights, :arrival_date, :date
    add_column :flights, :arrival_time, :string
    add_column :flights, :booking_url, :string
    add_column :flights, :departure_date, :date
    add_column :flights, :departure_time, :string
    add_column :flights, :end_airport, :string
    add_column :flights, :start_airport, :string
  end
end
