class SitemapsController < ApplicationController
  #caches_page :index
  def index
    @static_paths = [root_path, about_path]
    @places = Place.all
    @segments = Route.where(:published => true)
    @routes = RouteIndex.all
    @trips = Trip.where(:published => true)
    @stories = Report.all
    @users = User.all

    respond_to do |format|
      format.xml do
      end
    end
  end
end
