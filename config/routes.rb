Rails.application.routes.draw do
  resources :flights, only: [:index, :create]
  post '/flightsSearch', to: "flights#flight_search"
end
