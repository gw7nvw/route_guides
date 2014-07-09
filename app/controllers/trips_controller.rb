class TripsController < ApplicationController

def show
  @trip=Trip.find_by_id(params[:id])

end
end
