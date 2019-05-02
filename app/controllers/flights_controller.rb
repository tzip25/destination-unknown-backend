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

        flightHash = {}
        flightHash[:start_location] = flight["cityFrom"]
        flightHash[:start_airport] = flight["flyFrom"]
        flightHash[:end_airport] = flight["flyTo"]
        flightHash[:end_location] = flight["cityTo"]
        flightHash[:airline] = airline_name["name"]
        flightHash[:price] = flight["price"]
        flightHash[:departure_time] = Time.at(flight["dTime"])
        flightHash[:arrival_time] = Time.at(flight["aTime"])
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
