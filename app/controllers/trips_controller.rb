class TripsController < ApplicationController

def index
  @trips=Trip.all
end

def show
  @trip=Trip.find_by_id(params[:id])
      @route_types = Routetype.all
      @gradients = Gradient.all
      @alpines = Alpine.all
      @rivers = River.all
      @terrains = Terrain.all
      @place_types = Place_type.all

end
end
