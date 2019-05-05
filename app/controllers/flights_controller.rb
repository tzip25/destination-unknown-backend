require 'net/http'

class FlightsController < ApplicationController

  def index
    @flights = Flight.all
    render :json => @flights
  end

  def create
    old_departure_date = flight_params["departure_date"].split(" ")[1].split('/')
    old_departure_date[0], old_departure_date[1] = old_departure_date[1], old_departure_date[0]
    departure_date = old_departure_date.join('/').to_date
    flight_params["departure_date"] = departure_date

    old_arrival_date = flight_params["arrival_date"].split(" ")[1].split('/')
    old_arrival_date[0], old_arrival_date[1] = old_arrival_date[1], old_arrival_date[0]
    arrival_date = old_arrival_date.join('/').to_date
    flight_params["arrival_date"] = arrival_date
    @flight = Flight.find_or_create_by(flight_params)

    render :json => @flight
  end

  def flight_search
    airline_codes_url = URI.parse("https://api.skypicker.com/airlines")
    airline_codes = Net::HTTP.get_response(airline_codes_url ).body
    airline_codes_arr = JSON.parse(airline_codes)


    flight_search_url = URI.parse("https://api.skypicker.com/flights?flyFrom=#{params["start_location"]}&dateFrom=#{params["date"]}&dateTo=#{params["date"]}&curr=#{params["currency"]}&price_to=#{params["price"]}&partner=picky")

    puts flight_search_url

    flight_search_response = Net::HTTP.get_response(flight_search_url).body
    flightsArr = JSON.parse(flight_search_response)["data"]

    if flightsArr

      finalArr = flightsArr.map do |flight|

        airline_name = airline_codes_arr.find do |airline|
          airline["id"] == flight["airlines"][0]
        end

        departure_date_array = Time.at(flight["dTime"]).strftime("%F").split('-')
        new_departure = Time.new(departure_date_array[0].to_i, departure_date_array[1].to_i, departure_date_array[2].to_i)
        departure_date = Time.at(new_departure).strftime("%a %b/%d/%Y")
        departure_time = Time.at(flight["dTime"]).utc.strftime("%l:%M%P")

        arrival_date_array = Time.at(flight["aTime"]).strftime("%F").split('-')
        new_arrival = Time.new(arrival_date_array[0].to_i, arrival_date_array[1].to_i, arrival_date_array[2].to_i)
        arrival_date = Time.at(new_arrival).strftime("%a %b/%d/%Y")
        arrival_time = Time.at(flight["aTime"]).utc.strftime("%l:%M%P")

        price = (params["currency"] == "USD" ? flight["conversion"]["USD"] : flight["conversion"]["EUR"])
        airline_logo = URI.parse("https://images.kiwi.com/airlines/64/#{flight["airlines"][0]}.png")

        flightHash = {}
        flightHash[:start_location] = flight["cityFrom"]
        flightHash[:start_airport] = flight["flyFrom"]
        flightHash[:end_airport] = flight["flyTo"]
        flightHash[:end_location] = flight["cityTo"]
        flightHash[:airline] = airline_name["name"]
        flightHash[:currency] = params["currency"]
        flightHash[:price] = price
        flightHash[:departure_date] = departure_date
        flightHash[:departure_time] = departure_time
        flightHash[:arrival_date] = arrival_date
        flightHash[:arrival_time] = arrival_time
        flightHash[:booking_url] = flight["deep_link"]
        flightHash[:unx_dtime] = flight["dTime"]
        flightHash[:unx_atime] = flight["aTime"]
        flightHash[:airline_logo] = airline_logo

        flightHash
      end
      render :json => finalArr[0,50]
    else
      render :json => ["invalid"]
    end
  end

  def flight_params
    params.require(:flight).permit(:start_location, :end_location, :airline, :arrival_date, :arrival_time, :booking_url, :departure_date, :departure_time, :end_airport, :start_airport)
  end

end
