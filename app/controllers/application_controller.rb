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
      user=User.find_by_id(@current_user.id)
      user.lastVisited=Time.new()
      user.save
    end

    if params[:zoom] then @zoomlevel=params[:zoom] end
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
      if @items.first[0]=='p' and @items.first[2..-1].to_i>0 then @startplace=Place.find_by_id(@items.first[2..-1].to_i) end
      if (@items.first[0]=='r') and @items.first[2..-1].to_i!=0 then  routeId=@items.first[2..-1].to_i
        route=Route.find_by_signed_id(routeId)
        if route then @startplace=Place.find_by_id(route.startplace_id) end
      end
      if (@items.first[0]=='q') then
        arr=@items.first[2..-1].split('y')
        if arr.count==3 then @startplace=Place.find_by_id(arr[1].to_i) end
      end
      if @items.last[0]=='p' and @items.first[2..-1].to_i>0 then @endplace=Place.find_by_id(@items.last[2..-1].to_i) end
      if (@items.last[0]=='r') and @items.first[2..-1].to_i!=0 then  routeId=@items.last[2..-1].to_i
        route=Route.find_by_signed_id(routeId)
        if route then @endplace=Place.find_by_id(route.endplace_id) end
      end
      if (@items.last[0]=='q') then
        arr=@items.last[2..-1].split('y')
        if arr.count==3 then @endplace=Place.find_by_id(arr[2].to_i) end
      end
      if @startplace and @endplace then @description="An NZ Route Guide to the track/route from "+@startplace.name+" to "+@endplace.name end
   end 
end
