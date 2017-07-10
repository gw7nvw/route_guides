class SitemapsController < ApplicationController
  #caches_page :index
  def index
    @static_paths = [root_path, about_path]
    @places = Place.all
    @segments = Route.where(:published => true)
    @routes = RouteIndex.find_by_sql ['select max(id) as id, max(updated_at) as updated_at, startplace_id, endplace_id from route_indices where "isdest"=true and "fromdest"=true group by startplace_id, endplace_id']
    @trips = Trip.where(:published => true)
    @stories = Report.all
    @users = User.all

    respond_to do |format|
      format.xml do
      end
    end
  end
end
