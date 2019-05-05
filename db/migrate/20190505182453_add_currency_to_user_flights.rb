class AddCurrencyToUserFlights < ActiveRecord::Migration[5.2]
  def change
    add_column :user_flights, :currency, :string
  end
end
