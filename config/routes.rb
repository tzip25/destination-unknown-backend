Rails.application.routes.draw do
  resources :flights, only: [:index, :create]
  post '/flightsSearch', to: "flights#flight_search"
  post '/flightsSearchRound', to: "flights#flight_search_round"
  post '/signup', to: "users#create"
  post "/login", to: "auth#login"
  get "/auto_login", to: "auth#auto_login"
end
