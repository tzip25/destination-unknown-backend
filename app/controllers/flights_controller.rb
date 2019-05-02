class FlightsController < ApplicationController

  def index
    @flights = Flight.all
    render :json => @flights
  end

  def create
    @flight = Flight.create(flight_params)
    render :json => @flight
  end

  def flight_params
    params.require(:flight).permit(:start_location_id, :end_location_id, :date, :airline)
  end

end
