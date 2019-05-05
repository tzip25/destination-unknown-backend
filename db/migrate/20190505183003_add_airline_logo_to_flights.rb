class AddAirlineLogoToFlights < ActiveRecord::Migration[5.2]
  def change
    add_column :flights, :airline_logo, :string
  end
end
