class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #  protect_from_forgery with: :exception
   
  include SessionsHelper
  include RgeoHelper

  def signed_in_user
      redirect_to signin_url, notice: "Please sign in." unless signed_in?
  end

  def touch_user
    if signed_in? then
      @current_user.lastVisited=Time.new()
      @current_user.save
    end
  end

  def prepare_route_vars()
    @importances = RouteImportance.all
    @route_types = Routetype.all
    @gradients = Gradient.all
    @alpines = Alpine.all
    @alpinews = Alpinew.all
    @rivers = River.all
    @terrains = Terrain.all
  end

  def show_many()
      prepare_route_vars()
      routes=[]
      if !@id then @id=params[:id] end
      @items=@id.split('x')[1..-1]
      @showForward=1
      @showConditions=0
      @showLinks=0
      @url=@id
      @viewurl=@url.tr("e","v").gsub("xpn","xps")

      @edit=true #always, so forms are shown in editmode if present

      #determine start and endplace opf combined route 
      if @items.first[0]=='p' then @startplace=Place.find_by_id(@items.first[2..-1].to_i) end
      if @items.first[0]=='r' then  routeId=@items.first[2..-1].to_i
        route=Route.find_by_signed_id(routeId)
        @startplace=Place.find_by_id(route.startplace_id)
      end
      if @items.last[0]=='p' then @endplace=Place.find_by_id(@items.last[2..-1].to_i) end
      if @items.last[0]=='r' then  routeId=@items.last[2..-1].to_i
        route=Route.find_by_signed_id(routeId)
        if route then @endplace=Place.find_by_id(route.endplace_id) end
      end
   end 
end
