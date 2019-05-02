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
    url = URI.parse("https://api.skypicker.com/flights?flyFrom=#{params["start_location"]}&dateFrom=#{params["date"]}&dateTo=#{params["date"]}&price_to=#{params["price"]}&partner=picky"
)
    response = Net::HTTP.get_response(url).body
    flightsArr = JSON.parse(response)["data"]

    finalArr = flightsArr.map do |flight|
      flightHash = {}
      flightHash[:start_location] = flight["cityFrom"]
      flightHash[:end_location] = flight["cityTo"]
      flightHash[:airline] = flight["airlines"][0]
      flightHash[:price] = flight["price"]
      flightHash[:departure_time] = Time.at(flight["dTime"])
      flightHash[:arrival_time] = Time.at(flight["aTime"])
      flightHash[:booking_url] = flight["deep_link"]
      flightHash
    end
    render :json => finalArr[0,50]
  end

  def flight_params
    params.require(:flight).permit(:start_location, :end_location, :date, :budget, :airline)
  end

end
