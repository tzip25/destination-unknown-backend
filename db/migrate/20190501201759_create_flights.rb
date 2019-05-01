class CreateFlights < ActiveRecord::Migration[5.2]
  def change
    create_table :flights do |t|
      t.date :date
      t.integer :start_location_id
      t.integer :end_location_id
      t.timestamps
    end
  end
end
