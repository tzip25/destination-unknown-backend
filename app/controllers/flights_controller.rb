require 'net/http'

class FlightsController < ApplicationController

  def index
    flights = curr_user.flights

    updated_flights = flights.map do |flight|
      userflight = UserFlight.find_by(user_id: curr_user.id, flight_id: flight.id)
      flightHash = JSON.parse(flight.to_json)
      flightHash["price"] = userflight.price
      flightHash["currency"] = userflight.currency
      flightHash
    end
    render :json => updated_flights
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
    flight = Flight.find_or_create_by(flight_params)

    UserFlight.create(price: params["price"], currency: params["currency"], user_id: curr_user.id, outbound_flight_id: flight.id)
    flightHash = JSON.parse(flight.to_json)
    flightHash["price"] = params["price"]
    flightHash["currency"] = params["currency"]

    render :json => flightHash
  end

  def flightInfo(flight) 

    departure_date_array = Time.at(flight["dTime"]).strftime("%F").split('-')
    new_departure = Time.new(departure_date_array[0].to_i, departure_date_array[1].to_i, departure_date_array[2].to_i)
    departure_date = Time.at(new_departure).strftime("%a %b/%d/%Y")
    departure_time = Time.at(flight["dTime"]).utc.strftime("%l:%M%P")

    arrival_date_array = Time.at(flight["aTime"]).strftime("%F").split('-')
    new_arrival = Time.new(arrival_date_array[0].to_i, arrival_date_array[1].to_i, arrival_date_array[2].to_i)
    arrival_date = Time.at(new_arrival).strftime("%a %b/%d/%Y")
    arrival_time = Time.at(flight["aTime"]).utc.strftime("%l:%M%P")

    flightHash = {}
    flightHash[:start_location] = flight["cityFrom"]
    flightHash[:start_airport] = flight["flyFrom"]
    flightHash[:end_airport] = flight["flyTo"]
    flightHash[:end_location] = flight["cityTo"]
    flightHash[:departure_date] = departure_date
    flightHash[:departure_time] = departure_time
    flightHash[:arrival_date] = arrival_date
    flightHash[:arrival_time] = arrival_time
    flightHash[:unx_dtime] = flight["dTime"]
    flightHash[:unx_atime] = flight["aTime"]


    flightHash
  end

  def flight_search_round
    airline_codes_url = URI.parse("https://api.skypicker.com/airlines")
    airline_codes = Net::HTTP.get_response(airline_codes_url ).body
    airline_codes_arr = JSON.parse(airline_codes)

    airline_codes_url = URI.parse("https://api.skypicker.com/airlines")
    airline_codes = Net::HTTP.get_response(airline_codes_url ).body
    airline_codes_arr = JSON.parse(airline_codes)

    flight_search_url = URI.parse("https://api.skypicker.com/flights?fly_from=#{params["start_location"]}&fly_to=&date_from=#{params["date"]}&date_to=#{params["date"]}&return_from=#{params["return_date"]}&return_to=#{params["return_date"]}&flight_type=round&fly_days=%5B0,1,2,3,4,5,6%5D&fly_days_type=departure&ret_fly_days=%5B0,1,2,3,4,5,6%5D&ret_fly_days_type=departure&one_for_city=0&one_per_date=0&direct_flights=0&locale=en&partner=picky&curr=#{params["currency"]}&max_stopovers=0&price_from=1&price_to=#{params["price"]}&ret_from_diff_airport=1&ret_to_diff_airport=1&limit=200&sort=price&asc=1")

    flight_search_response = Net::HTTP.get_response(flight_search_url).body
    flightsArr = JSON.parse(flight_search_response)["data"]
    
    finalArr = flightsArr.map do |flight|
      round_trip_details = {}
      round_trip_array = []

      first_flight = flight["route"][0]
      second_flight = flight["route"][1]
      
      price = (params["currency"] == "USD" ? flight["conversion"]["USD"] : flight["conversion"]["EUR"])

      round_trip_details[:currency] = params["currency"]
      round_trip_details[:price] = price
      round_trip_details[:booking_url] = flight["deep_link"]
      
      first_flight_obj = flightInfo(first_flight)
      first_flight_airline_logo = URI.parse("https://images.kiwi.com/airlines/64/#{first_flight["airline"]}.png")
      first_flight_airline_name = airline_codes_arr.find do |airline|
        airline["id"] == first_flight["airline"]
      end

      second_flight_obj = flightInfo(second_flight)
      second_flight_airline_logo = URI.parse("https://images.kiwi.com/airlines/64/#{second_flight["airline"]}.png")
      second_flight_airline_name = airline_codes_arr.find do |airline|
        airline["id"] == second_flight["airline"]
      end

      first_flight_obj[:airline] = first_flight_airline_name["name"]
      first_flight_obj[:airline_logo] = first_flight_airline_logo

      second_flight_obj[:airline] = second_flight_airline_name["name"]
      second_flight_obj[:airline_logo] = second_flight_airline_logo

      round_trip_array.push(round_trip_details, first_flight_obj, second_flight_obj)
    end
    render :json => finalArr
    
  end

  

  def flight_search
    flight_search_url = URI.parse("https://api.skypicker.com/flights?fly_from=#{params["start_location"]}&dateFrom=#{params["date"]}&dateTo=#{params["date"]}&curr=#{params["currency"]}&price_to=#{params["price"]}&partner=picky")

    flight_search_response = Net::HTTP.get_response(flight_search_url).body
    flightsArr = JSON.parse(flight_search_response)["data"]

    airline_codes_url = URI.parse("https://api.skypicker.com/airlines")
    airline_codes = Net::HTTP.get_response(airline_codes_url ).body
    airline_codes_arr = JSON.parse(airline_codes)

    if flightsArr

      finalArr = flightsArr.map do |flight|

        airline_name = airline_codes_arr.find do |airline|
          airline["id"] == flight["airlines"][0]
        end

        price = (params["currency"] == "USD" ? flight["conversion"]["USD"] : flight["conversion"]["EUR"])
        airline_logo = URI.parse("https://images.kiwi.com/airlines/64/#{flight["airlines"][0]}.png")

        flight_obj = flightInfo(flight)
        flight_obj[:airline] = airline_name["name"]
        flight_obj[:currency] = params["currency"]
        flight_obj[:price] = price
        flight_obj[:booking_url] = flight["deep_link"]
        flight_obj[:airline_logo] = airline_logo

        flight_obj
      end
      render :json => finalArr[0,200]
    else
      render :json => ["invalid"]
    end
  end

  def flight_params
    params.require(:flight).permit(:start_location, :end_location, :airline, :arrival_date, :arrival_time, :booking_url, :departure_date, :departure_time, :end_airport, :start_airport, :airline_logo)
  end

end
