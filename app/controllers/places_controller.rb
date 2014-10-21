
class PlacesController < ApplicationController
 before_action :signed_in_user, only: [:edit, :update, :new, :create]
 before_action :touch_user

def new
    @edit=true
    @place=Place.new
    # default preojection is NZTM2000
    @place.projection_id=2193
end

def index
    @places = Place.all.order(:name)
end



def create


    @place = Place.new(place_params)

    convert_location_params()

    #revision control
    @place.createdBy_id = @current_user.id #current_user.id
    @place.updatedBy_id = @current_user.id #current_user.id
    # but doesn;t handle location ... so

    @url=params[:url]

    if @place.save
      flash[:success] = "New place added, id:"+@place.id.to_s
      @id=@place.id

      if @url and @url.include?('x')
        #show routes screen
        #if this is 1st place, next url is select next place.
        #if this s asubsequent place, then next url is create route
        if @url.include?('xpb') then
          @id=@url.gsub('xpn','xrnxpb'+@id.to_s)
        else
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
      @edit=true
      if(@url and @url.include?('x')) then 
         @id=@url
         show_many() 
      end
      render 'new'
    end
  end



  def show
    prepare_route_vars()
    # default visibility 
    @showForward=1
    @showReverse=1
    @showConditions=1
    @showLinks=1

    if !@id then @id=params[:id] end

    @edit=false
    if( !(@place = Place.find_by_id(@id))) then 
    #place does not exist - return to home
       redirect_to root_url
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
        if @url.include?('xpb') then
          @id=@url.gsub('xps','xrnxpb'+@id.to_s)
        else
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

    else
    #place does not exist - return to home
    redirect_to root_url
    end

  end
 
 
  def update
    #add to trip
    if (params[:add]) 
      @trip=Trip.find_by_id(@current_user.currenttrip)
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

      #refrese show' variables 
      show()
      #render the panel
      render 'show'
    end

    # Save current place
    if (params[:save]) 
       @url=params[:url]
       @viewurl=@url.tr("e","v")

       if( !@place = Place.find_by_id(params[:id]))
          #tried to update a nonexistant place
          @edit=true
          render 'edit'
       end


       @place.attributes=place_params
       convert_location_params()

       #timestanps
       @place.updatedBy_id = @current_user.id #current_user.id
       @place.updated_at = Time.new()

       if @place.save
         flash[:success] = "Updated place, id:"+@place.id.to_s
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
         @edit=true
         render 'edit'
       end
    end

 if (params[:delete])

   if(!trip=TripDetail.find_by(:place_id => params[:id]))

     if(!route=Route.find_by(:startplace_id => params[:id]))

       if(!route=Route.find_by(:endplace_id => params[:id]))
         place=Place.find_by_id(params[:id])
         if place.destroy
           flash[:success] = "Place deleted, id:"+params[:id]
           redirect_to '/'
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
  
  end

end

  def destroy
  end

  private 
  def place_params
    params.require(:place).permit(:name, :place_type, :place_owner, :description, :location, :altitude, :x, :y, :projection_id, :links)
  end

  def convert_location_params
    #recalculate location from passed x,y params
    if(place_params[:x] and place_params[:x].length>0) then @place.x=place_params[:x].to_f end
    if(place_params[:y] and place_params[:y].length>0) then @place.y=place_params[:y].to_f end
    @place.altitude = place_params[:altitude].to_i

    if(@place.x and @place.y)
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
