class AddStartLocationToFlight < ActiveRecord::Migration[5.2]
  def change
    add_column :flights, :start_location, :string
    add_column :flights, :end_location, :string
    remove_column :flights, :end_location_id
    remove_column :flights, :start_location_id
  end
end
