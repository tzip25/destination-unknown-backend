class AddAirlineToFlight < ActiveRecord::Migration[5.2]
  def change
    add_column :flights, :airline, :string
  end
end
