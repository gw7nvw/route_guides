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
    @importances = RouteImportance.all.order(:id)
    @route_types = Routetype.all.order(:id)
    @gradients = Gradient.all.order(:id)
    @alpines = Alpine.all.order(:id)
    @alpinews = Alpinew.all.order(:id)
    @rivers = River.all.order(:id)
    @terrains = Terrain.all.order(:id)
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
      if @items.last[0]=='p' and @items.last[2..-1].to_i>0 then @endplace=Place.find_by_id(@items.last[2..-1].to_i) end
      if (@items.last[0]=='r') and @items.last[2..-1].to_i!=0 then  routeId=@items.last[2..-1].to_i
        route=Route.find_by_signed_id(routeId)
        if route then @endplace=Place.find_by_id(route.endplace_id) end
      end
      if (@items.last[0]=='q') then
        arr=@items.last[2..-1].split('y')
        if arr.count==3 then @endplace=Place.find_by_id(arr[2].to_i) end
      end
      if @startplace and @endplace then @description="An NZ Route Guide to the track/route from "+@startplace.name+" to "+@endplace.name end
   end 

def route_to_gpx(routes)

   xml = REXML::Document.new
   gpx = xml.add_element 'gpx', {'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
     'xmlns' => 'http://www.topografix.com/GPX/1/0',
     'xsi:schemaLocation' => 'http://www.topografix.com/GPX/1/0 http://www.topografix.com/GPX/1/0/gpx.xsd',
     'version' => '1.0', 'creator' => 'http://routeguides.co.nz/'}

   if routes and routes.count>0 then 
     route=routes.first

     if routes and routes.first.startplace and routes.last.endplace then
       name=routes.first.startplace.name+" to "+routes.last.endplace.name
       if routes.count==1 then name+=" via "+routes.first.via end
     else
       name="route"
     end
     #currently just use data from first route segment for creator, etc 
     trk = gpx.add_element 'trk'
     trk.add_element('name').add REXML::Text.new(name)
     if route.createdBy_id then trk.add_element('author').add REXML::Text.new(route.createdBy.name) end
     trk.add_element('url').add REXML::Text.new('http://routeguides.co.nz/routes/'+route.id.to_s)
     trk.add_element('time').add REXML::Text.new(route.created_at.to_s)
  
     routes.each do |route|
  
       trkseg = trk.add_element 'trkseg'
  
       #and reverse the direction if required
  
       if route.location and route.location.points and route.location.points.count>0 then
         route.location.points.each do |pt|
           elem = trkseg.add(REXML::Element.new('trkpt'))
           elem.add_attributes({'lat' => pt.y.to_s, 'lon' => pt.x.to_s})
           elem.add_element('ele').add(REXML::Text.new(pt.z.to_s))
         end
       end
    end
  end
  output = String.new
  formatter = REXML::Formatters::Pretty.new
  formatter.write(gpx, output)
  return output
end
end
