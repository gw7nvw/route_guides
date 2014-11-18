class RoutesController < ApplicationController
require "rexml/document"

#get altitude from DEM if not set
 before_action :signed_in_user, only: [:edit, :update, :new, :create]
 before_action :touch_user
 
  def leg_index
    @routes = Route.all.order(:name)
  end

  def index
    @route_index = RouteIndex.select(:startplace_id, :endplace_id).uniq
  end

  def site_index
    @route_index = RouteIndex.select(:startplace_id, :endplace_id).uniq
    @trips=Trip.where(published: true).order(:name)
    @reports = Report.all.order(:name)
    @places = Place.order(:name)
  end

  def search
     @trip=true
     prepare_route_vars()
     @searchNow=true
     
     if(params[:route_startplace_id] and params[:route_endplace_id]) then find() end

  end

  def find
     @trip=true
     if params[:route_startplace_id] and sp=Place.find_by_id(params[:route_startplace_id]) then
         @startplace=params[:route_startplace_id]
         @startplacename=sp.name
     else
         @startplace=nil
         @startplacename=""
     end
     if params[:route_endplace_id] and ep=Place.find_by_id(params[:route_endplace_id]) then
         @endplace=params[:route_endplace_id]
         @endplacename=ep.name
     else
         @endplace=nil
         @endplacename=""
     end

     placea=Place.find_by_id(params[:route_startplace_id].to_i)
     if placea then
       @route_ids=placea.adjoiningPlaces(params[:route_endplace_id].to_i,true,nil,nil,nil)
     else 
       @route_ids=nil
     end 
     prepare_route_vars()

     render 'search'
  end

  def new
    @edit=true
    @route = Route.new
    @route.published=true
    prepare_route_vars()
  end

  def many
    @items=params[:route].split('x')[1..-1]
    current_user()
    if (!signed_in?) then 
      redirect_to '/signin'
    else
      @trip=Trip.find_by_id(@current_user.currenttrip)
      @items.each do |item|
        itemno=item[2..-1].to_i
        if item[0]=='p' then
          @trip_details = TripDetail.new
          @trip_details.showForward=true;
          @trip_details.is_reverse=false
          @trip_details.trip = @trip
          @trip_details.place_id = itemno
          @trip_details.showConditions=false;
          @trip_details.showLinks=false;
        end
        if item[0]=='r' then
          @trip_details = TripDetail.new
          @trip_details.showForward=true;
          @trip_details.is_reverse=false
          @trip_details.trip = @trip
          @trip_details.route_id = itemno
          @trip_details.showConditions=false;
          @trip_details.showLinks=false;
        end
        if(@trip.trip_details.max)
          @trip_details.order = @trip.trip_details.max.id+1
        else
          @trip_details.order = 1
        end
          @trip_details.save
        flash[:success]="Added route to trip"
      end
      @trip= trip=Trip.find_by_id(@current_user.currenttrip)
      prepare_route_vars()
      render '/trips/show'
    end 
 end

 def create
    @route = Route.new(route_params)    
    prepare_route_vars()
    @route.createdBy_id = @current_user.id #current_user.id
    @route.updatedBy_id = @current_user.id #current_user.id
    route_add_altitude()
    # but doesn;t handle location ... so
    @url=params[:url]

    dupRoute=Route.find_by_sql ['select * from routes where "startplace_id"=? and "endplace_id"=? and via=?',@route.startplace_id, @route.endplace_id, @route.via]
     logger.debug dupRoute.count
    if dupRoute.count>0  then 
       #save already in procgress
       logger.debug "errorwith 409"
       render nothing: true, status: 409
    else 
      success=@route.save
      if success
        flash[:success] = "New route added, id:"+@route.id.to_s
  

        @edit=false
        @showForward=1
        @showConditions=0
        @showLinks=1
        if @url and @url.include?('x')
          #show routes screen
          #if this is 1st place, next url is select next place.
          #if this s asubsequent place, then next url is create route
          @url=@url.gsub('xrn','xrv'+@route.id.to_s)
          @url=@url+'xps'
          @id=@url
          show_many()
  
          #show the show many screen
          render '/routes/show_many'
        else
          render 'show'
        end
      else
        if(@url and @url.include?('x')) then 
           @id=@url
           show_many() 
        end
  
        @edit=true
        render 'new'
      end
   
    end 
 end

def show
    if params[:editlinks] then @editlinks=true end

    prepare_route_vars()
    routes=[]
    if !@id then @id=params[:id] end
    if @id[0]!="x" then
       show_single()
    else
      show_many()
      if @id.include?('xps') and !signed_in? then 
        redirect_to '/signin'
      else
       respond_to do |wants|
        wants.js do
         # if @startplace and @endplace then
            render '/routes/show_many'
         # else
         #   redirect_to root_url
         # end
        end
        wants.html do
         # if @startplace and @endplace then
            render '/routes/show_many'
         # else
         #   redirect_to root_url
         # end
        end
        wants.gpx do
          if(@startplace and @endplace)
            @items.each do |item|
               if item[0]=='r' then routes=routes+[item[2..-1].to_i] end
            end
            xml = route_to_gpx(routes)
            response.headers['Content-Disposition'] = 'attachment; filename=' + (@startplace.name+' to '+@endplace.name).gsub(/[\\\/\s]/, '_') + '.gpx'
            render :xml => xml
          end
        end
       end
      end 
    end
end


  def show_single
    @edit=false

    # default visibility 
    @showForward=1
    @showConditions=0
    @showLinks=1


    if( @route = Route.find_by_signed_id(params[:id])) then
      if(@route.location)
        @route.location=@route.location.as_text
      end
      @referring_page='/routes/'+@route.id.to_s
    else
      redirect_to root_url
    end

    respond_to do |wants|
      wants.html do
      end 
      wants.js do
      end 
      wants.gpx do  
        xml = route_to_gpx([@route.id])
        response.headers['Content-Disposition'] = 'attachment; filename=' + @route.name.gsub(/[\\\/\s]/, '_') + '.gpx'
        render :xml => xml 
      end 
    end 
  end

  def edit
    @edit=true
    if( @route = Route.find_by_signed_id(params[:id]))
    then
      if(@route.location) 
         @route.location=@route.location.as_text
      end
      @route.experienced_at=nil
      prepare_route_vars()
    else
      redirect_to root_url
    end
  end

  def update
    @route = Route.find_by_signed_id(params[:id])
    logger.debug params[:id]

    add=false
    if (params[:addfw])
      route=@route
      add=true
    end

    if (params[:addrv])
      route=@route.reverse
      add=true
    end

    if (add)
      if (!signed_in?) then 
        redirect_to '/signin'
      else
        trip=Trip.find_by_id(@current_user.currenttrip)
        trip_details = TripDetail.new
        if ((!route.description or route.description.length<1) and route.reverse_description and route.reverse_description.length>0) then
          trip_details.showForward=false;
        else
          trip_details.showForward=true;
        end
        trip_details.trip_id = trip.id
        trip_details.route_id = route.id
        trip_details.showConditions=false;
        trip_details.showLinks=false;
  
        if(trip.trip_details.max)
          trip_details.order = trip.trip_details.max.id+1
        else
          trip_details.order = 1
        end
        trip_details.save
        flash[:success]="Added route to trip"
  
        @trip= trip=Trip.find_by_id(@current_user.currenttrip)
        prepare_route_vars()
        render '/trips/show'
      end
    end

    if (params[:save])
       @url=params[:url]
       @viewurl=@url.tr("e","v")


      prepare_route_vars()

      # but doesn;t handle location ... so

      @route.attributes=route_params
      route_add_altitude()

      @route.updated_at=Time.new()
      @route.updatedBy_id = @current_user.id #current_user.id
      if @route.save
        flash[:success] = "Route updated, id:"+@route.id.to_s
        if @url and @url.include?('x')
            #show routes screen
            #get all data for show many
            @id=@viewurl
            show_many()

            #show the show many screen
            render '/routes/show_many'
        else
          show()
          render 'show'
        end


      else
        flash[:error] = "Error creating route"
        @edit=true
        render 'edit'
      end
    end
  

    if (params[:delete])
    
      if(!trip=TripDetail.find_by(:route_id => params[:id])) 
         
        route=Route.find_by_id(params[:id].to_i.abs)
        links=route.links
        links.each do |l| 
           l.destroy
        end
        if route.destroy
          flash[:success] = "Route deleted, id:"+params[:id]
          redirect_to '/'
        else
          edit()
          render 'edit'
        end 
      else
        flash[:error] = "Trip "+trip.id.to_s+" uses this route, cannot delete"
        edit()
        render 'edit'
      end
   end
end

def route_add_altitude
  if (@route.location and @route.location.length>0) then
    #check for alt data
    totalAlt=0
    @route.location.points.each do |p|
      totalAlt+=p.z
    end
    #none present? then calculate
    if totalAlt==0 then
      linestr="LINESTRING("
      @route.location.points.each do |p|
         if linestr.length>11 then linestr+="," end
         #get alt from map if it is blank or 0
         altArr=Dem30.find_by_sql ["
            select ST_Value(rast, ST_GeomFromText(?,4326))  rid
               from dem30s
               where ST_Intersects(rast,ST_GeomFromText(?,4326));",
               'POINT('+p.x.to_s+' '+p.y.to_s+')',
               'POINT('+p.x.to_s+' '+p.y.to_s+')']
  
         linestr+=p.x.to_s+" "+p.y.to_s+" "+altArr.first.try(:rid).to_s
      end
      @route.location=linestr+")"
    end
  end
end


def route_to_gpx(routes)

   xml = REXML::Document.new
   gpx = xml.add_element 'gpx', {'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
     'xmlns' => 'http://www.topografix.com/GPX/1/0',
     'xsi:schemaLocation' => 'http://www.topografix.com/GPX/1/0 http://www.topografix.com/GPX/1/0/gpx.xsd',
     'version' => '1.0', 'creator' => 'http://routeguides.co.nz/'}
   
   route=Route.find_by_signed_id(routes.first)

   #currently just use data from first route segment for creator, etc 
   trk = gpx.add_element 'trk'
   trk.add_element('name').add REXML::Text.new(route.name)
   trk.add_element('author').add REXML::Text.new(route.createdBy.name) 
   trk.add_element('url').add REXML::Text.new('http://routeguides.co.nz/routes/'+route.id.to_s)
   trk.add_element('time').add REXML::Text.new(route.created_at.to_s)

   routes.each do |route_id|

     trkseg = trk.add_element 'trkseg'
      
     route=Route.find_by_signed_id(route_id)

     #and reverse the direction if required

     route.location.points.each do |pt|
       elem = trkseg.add(REXML::Element.new('trkpt'))
       elem.add_attributes({'lat' => pt.y.to_s, 'lon' => pt.x.to_s})
       elem.add_element('ele').add(REXML::Text.new(pt.z.to_s))
     end
  end
  output = String.new
  formatter = REXML::Formatters::Pretty.new
  formatter.write(gpx, output)
  return output
end

  private
  def route_params
    params.require(:route).permit(
       :via, 
       :routetype_id,
       :description,        
       :reverse_description,        
       :gradient_id,
       :terrain_id,
       :alpinesummer_id,
       :river_id,
       :alpinewinter_id,
       :winterdescription,
       :startplace_id,
       :endplace_id,
       :links,
       :location,
       :time,
       :distance,
       :datasource,
       :importance_id,
       :experienced_at,
       :published)
  end

end
