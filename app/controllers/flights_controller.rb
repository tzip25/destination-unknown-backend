require 'net/http'

class FlightsController < ApplicationController

  def index
    @flights = Flight.all
    render :json => @flights
  end

  def create
    @flight = Flight.create(flight_params)
    render :json => @flight
  end

  def flight_search
    airline_codes_url = URI.parse("https://api.skypicker.com/airlines"
    )
    airline_codes = Net::HTTP.get_response(airline_codes_url ).body
    airline_codes_arr = JSON.parse(airline_codes)


    flight_search_url = URI.parse("https://api.skypicker.com/flights?flyFrom=#{params["start_location"]}&dateFrom=#{params["date"]}&dateTo=#{params["date"]}&price_to=#{params["price"]}&partner=picky"
)
    flight_search_response = Net::HTTP.get_response(flight_search_url).body
    flightsArr = JSON.parse(flight_search_response)["data"]

    if flightsArr

      finalArr = flightsArr.map do |flight|

        airline_name = airline_codes_arr.find do |airline|
          airline["id"] == flight["airlines"][0]
        end
        
        departure_date_array = Time.at(flight["dTime"]).strftime("%F").split('-')
        departure_date_array[1], departure_date_array[2] = departure_date_array[2], departure_date_array[1]
        new_departure = Time.new(departure_date_array[0].to_i, departure_date_array[1].to_i, departure_date_array[2].to_i)
        departure_date = Time.at(new_departure).strftime("%a %D")
        departure_time = Time.at(flight["dTime"]).utc.strftime("%l:%M%P")

        arrival_date_array = Time.at(flight["aTime"]).strftime("%F").split('-')
        arrival_date_array[1], arrival_date_array[2] = arrival_date_array[2], arrival_date_array[1]
        new_arrival = Time.new(arrival_date_array[0].to_i, arrival_date_array[1].to_i, arrival_date_array[2].to_i)
        arrival_date = Time.at(new_arrival).strftime("%a %D")
        arrival_time = Time.at(flight["aTime"]).utc.strftime("%l:%M%P")

        flightHash = {}
        flightHash[:start_location] = flight["cityFrom"]
        flightHash[:start_airport] = flight["flyFrom"]
        flightHash[:end_airport] = flight["flyTo"]
        flightHash[:end_location] = flight["cityTo"]
        flightHash[:airline] = airline_name["name"]
        flightHash[:price] = flight["price"]
        flightHash[:departure_date] = departure_date
        flightHash[:departure_time] = departure_time
        flightHash[:arrival_date] = arrival_date
        flightHash[:arrival_time] = arrival_time
        flightHash[:booking_url] = flight["deep_link"]
        flightHash
      end
      render :json => finalArr[0,50]
    else
      render :json => ["invalid"]
    end
  end

  def flight_params
    params.require(:flight).permit(:start_location, :end_location, :date, :budget, :airline)
  end

end
