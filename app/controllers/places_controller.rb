
class PlacesController < ApplicationController
 before_action :signed_in_user, only: [:edit, :new, :create]
 before_action :touch_user

def adj_route
if request.xhr?
  # respond to Ajax request
   prepare_route_vars()
   p=Place.find_by_id(params[:startplace_id])
   rt_list=p.adjoiningPlacesFast(params[:endplace_id].to_i,false,nil,nil,nil)
   @rt_list=[]
   if params[:show]=="fastest" then
      @rt_list=[rt_list.sort_by{|r| r.time or 0}.first]
   end

   if params[:show]=="shortest" then
      @rt_list=[rt_list.sort_by{|r| r.distance or 0}.first]
   end

   if params[:show]=="all" then
      @rt_list=rt_list.sort_by{|r| r.time or 0}
   end

   @render_to=params[:loc]
#   render "adj_route"

else
  redirect_to root_url
end
end

def new
    @edit=true
    @place=Place.new
    # default preojection is NZTM2000
    @place.projection_id=2193
end

def index

    @order=params[:order]
    @searchtext=params[:searchtext]
    whereclause="true"
    if params[:searchtext] then
       whereclause=whereclause+" and lower(name) like '%%"+@searchtext.downcase+"%%'"
    end

    @places=Place.where(whereclause)
    if params[:order]=='latest' then
      @places=@places.order('updated_at desc')
    else
      @places=@places.order('name')
    end
    @count=@places.count
    @places=@places.paginate(:per_page => 40, :page => params[:page])

end



def create


    @place = Place.new(place_params)

    convert_location_params()

    #revision control
    @place.createdBy_id = @current_user.id #current_user.id
    @place.updatedBy_id = @current_user.id #current_user.id
    # but doesn;t handle location ... so

    @url=params[:url]

    dupPlace=Place.find_by_sql ['select * from places where "name"=? and location=?',@place.name, @place.location]
     logger.debug dupPlace.count
    if (session[:save] and (Time.now - session[:save])<60) or dupPlace.count>0  then
       #save already in procgress
       logger.debug "errorwith 409"
       render nothing: true, status: 409
    else
      session[:save]=Time.now
      success=@place.save
      session[:save]=nil
      if success
       @place.create_new_instance
        flash[:success] = "New place added, id:"+@place.id.to_s
        @id=@place.id
  
        if @url and @url.include?('x')
          #show routes screen
          #if this is 1st place, next url is select next place.
          #if this s asubsequent place, then next url is create route

          #cut and split
          if @url and @url.include?('xrc') then
            @id=split_route(@url, @place) 
            if !flash[:error] then flash[:success]="Success: route split. Now please edit the details of the first half of the split route" end
            match=true
          end 

          if !match and @url and @url.include?('xpb') then
            @id=@url.gsub('xpn','xrnxpb'+@id.to_s)
            match=true
          end
 
          if !match then
            @id=@url.gsub('xpn','xpb'+@id.to_s+'xps')
          end
          show_many()

          #show the show many screen
          render '/routes/show_many'
        else
          show()
          render 'show'
        end
      else
        flash[:error] = "Error creating place"
         if @url and @url.include?('x')
            #show routes screen
            #get all data for show many
            @id=@url
            @editplace=@place
            show_many()
            render '/routes/show_many'   
         else
           @edit=true
           render 'new'
         end
      end
    end
  end



  def show
    prepare_route_vars()
    # default visibility 
    @showForward=1
    @showReverse=1
    @showConditions=1
    @showLinks=1

    if params[:editlinks] then @editlinks=true end

    if !@id then @id=params[:id] end

    @edit=false
    if params[:version] then
      @place = Place.find_by_id(@id)
      if @place then
        @place.assign_attributes(PlaceInstance.find_by_id(params[:version]).attributes.except("id", "place_id"))
        @version=params[:version]
      end
    else
      @place = Place.find_by_id(@id) 
      if @place then @version=(PlaceInstance.find_by_sql [ "select id from place_instances where place_id=? order by updated_at desc limit 1", @place.id.to_s ]).first.try('id') end
    end
    if !@place
    #place does not exist - return to home
       redirect_to '/places'
    else    
       @referring_page='/places/'+@place.id.to_s
    end
  end

  def select
  @url=params[:url]
  @id=params[:route_startplace_id]
    if @id and @id.to_i>0 and place = Place.find_by_id(@id) then
      if @url and @url.include?('s')
        #show routes screen
        #if this is 1st place, next url is select next place.
        #if this s asubsequent place, then next url is create route
        if @url and @url.include?('xrc') then
          @id=split_route(@url, place) 
            if !flash[:error] then flash[:success]="Success: route split. Now please edit the details of the first half of the split route" end
          match=true
        end 

        if !match and @url and @url.include?('xpb') then
          @id=@url.gsub('xps','xrnxpb'+@id.to_s)
          match=true
        end
         if !match then
          @id=@url.gsub('xps','xpb'+@id.to_s+'xps')
        end

        show_many()

        #show the show many screen
        render '/routes/show_many'
     else
            redirect_to root_url
     end
   else
     @id=@url
     show_many()

     #show the show many screen
     render '/routes/show_many'
   end
  end

  def edit
    @edit=true
    if( @place = Place.find_by_id(params[:id]))
    #show
      xstr = @place.location.x.to_s
      ystr = @place.location.y.to_s
      
      @place.location = xstr+" "+ystr
      @place.experienced_at=nil if @current_user!=@place.updatedBy 

    else
    #place does not exist - return to home
      redirect_to '/places'
    end

  end
 
 
  def update
    #add to trip
    if (params[:add]) 
      if (!signed_in?) then
        if (!is_guest?) then
          create_guest()
          reload_required=true
        end
      end
      if signed_in? then @trip=Trip.find_by_id(@current_user.currenttrip) end
      if is_guest? then @trip=Trip.find_by_id(@current_guest.currenttrip) end

      if @trip
        @trip_details = TripDetail.new
        @trip_details.trip = @trip
        @trip_details.place_id = params[:id]
        @trip_details.showForward=true;
        @trip_details.showReverse=false;
        @trip_details.showConditions=false;
        @trip_details.showLinks=false;
  
        last_td=TripDetail.where(trip_id: @trip.id).order(:order).last()
        if(last_td)  then
          @trip_details.order = last_td.order+1 
        else 
          @trip_details.order=1 
        end
        @trip_details.save
  
        flash[:success] = "Added place to trip"
      else
        flash[:error] = "couldn't find your trip"
      end
      #refrese show' variables 
      show()
      #render the panel
      if reload_required then
         redirect_to '/reload'
      else
        render 'show'
      end
    end

    # Save current place
    if (params[:save]) 
      if signed_in?
       @url=params[:url] || ""

       if( !@place = Place.find_by_id(params[:id]))
         flash[:error] = "Place does not exist: "+@place.id.to_s

          #tried to update a nonexistant place
          @edit=true
          render 'edit'
       end

       @place.attributes=place_params
       convert_location_params()

       #timestanps
       @place.updatedBy_id = @current_user.id #current_user.id
#       @place.updated_at = Time.new()

       if @place.save
         flash[:success] = "Updated place, id:"+@place.id.to_s
         if @url and @url.include?('xrc') then
            @viewurl=split_route(@url, @place)
              if !flash[:error] then flash[:success]="Success: route split. Now please edit the details of the first half of the split route" end
            match=true
         else
           @viewurl=@url.tr("e","v")
         end

         @place.create_new_instance
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
         #flash[:error] = "Form contains errors"+@place.id.to_s
         if @url and @url.include?('x')
            #show routes screen
            #get all data for show many
            @id=@url
            @editplace=@place
            show_many()
            render 'routes/show_many'
         else
           @edit=true
           render 'edit'
         end
       end
    else #signed_in
      redirect_to signin_url+"?referring_url="+URI.escape(request.fullpath), notice: "Please sign in." 

    end
  end
  if (params[:delete])
   if signed_in? then
     if(!trip=TripDetail.find_by(:place_id => params[:id]))
  
       if(!route=Route.find_by(:startplace_id => params[:id]))
  
         if(!route=Route.find_by(:endplace_id => params[:id]))
           place=Place.find_by_id(params[:id])
           links=place.links
           links.each do |l|
             l.destroy
           end
  
           if place.destroy
             flash[:success] = "Place deleted, id:"+params[:id]
             redirect_to '/places'
           else
             edit()
             render 'edit'
           end
         else
           flash[:error] = "Route "+route.name+" uses this place, cannot delete"
           edit()
           render 'edit'
         end
       else
         flash[:error] = "Route "+route.name+" uses this place, cannot delete"
         edit()
         render 'edit'
       end
      else
  
        flash[:error] = "Trip "+trip.id.to_s+" uses this place, cannot delete"
        edit()
        render 'edit'
      end
   
    else #signed in
      redirect_to signin_url+"?referring_url="+URI.escape(request.fullpath), notice: "Please sign in." 
    end
  end 
end

  def destroy
  end

def split_route(url, place)
  route_id=url.split('xrc')[1].split('x')[0].to_f
  route=Route.find_by_signed_id(route_id)
  if route then
    route.updatedBy=@current_user if @current_user
    r2=route.split(place) 
    if (!route.customerrors) and r2 then
      url=url.gsub('xrc','xrm').gsub('xps','').gsub('xpn','').gsub(/xpe.*/,'')+"xrv"+r2.id.to_s
    else
      url=url.gsub('xpn','xpe'+place.id.to_s)
      flash[:error]=route.customerrors+'. Update the place (below) and save to try again'
      puts route.customerrors
    end
  else
    flash[:error]="Error: Route does not exist"
  end
  url
end

  private 
  def place_params
    params.require(:place).permit(:name, :place_type, :place_owner, :description, :location, :altitude, :x, :y, :projection_id, :links, :experienced_at)
  end

  def convert_location_params
    #recalculate location from passed x,y params
  #  if(place_params[:x] and place_params[:x].length>0) then @place.x=place_params[:x].to_f end
  #  if(place_params[:y] and place_params[:y].length>0) then @place.y=place_params[:y].to_f end
  #  @place.altitude = place_params[:altitude].to_i

    if(@place.x and @place.y and @place.projection)
       # convert to WGS84 (EPSG4326) fro database 
       fromproj4s= @place.projection.proj4
       toproj4s=  Projection.find_by_id(4326).proj4

       fromproj=RGeo::CoordSys::Proj4.new(fromproj4s)
       toproj=RGeo::CoordSys::Proj4.new(toproj4s)

       xyarr=RGeo::CoordSys::Proj4::transform_coords(fromproj,toproj,@place.x,@place.y)

       params[:location]=xyarr[0].to_s+" "+xyarr[1].to_s
       @place.location='POINT('+params[:location]+')'

       #if altitude is not entered, calculate it from map 

       if place_params[:altitude].to_i == 0
         #get alt from map if it is blank or 0
         altArr=Dem30.find_by_sql ["
            select ST_Value(rast, ST_GeomFromText(?,4326))  rid
               from dem30s
               where ST_Intersects(rast,ST_GeomFromText(?,4326));",
               'POINT('+params[:location]+')',
               'POINT('+params[:location]+')']

         @place.altitude=altArr.first.try(:rid).to_i
       end
    end
  end
end
