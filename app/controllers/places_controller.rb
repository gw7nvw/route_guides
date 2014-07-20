class PlacesController < ApplicationController
 before_action :signed_in_user, only: [:edit, :update, :new, :create]

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
    @place_instance=PlaceInstance.new(@place.attributes)
    # but doesn;t handle location ... so

    if @place.save
      @place_instance.place_id=@place.id
      if @place_instance.save     
        flash[:success] = "New place added, id:"+@place.id.to_s
        @id=@place.id
        #refresh variables
        show()
      
        #render show panel
        render 'show'

      else
        # Handle an unsuccessful save.
        flash[:error] = "Error creating instance"
        @edit=true
        render 'new'
      end
    else
      flash[:error] = "Error creating place"
      @edit=true
      render 'new'
    end
  end



  def show
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
       if( !@place = Place.find_by_id(params[:id]))
          #tried to update a nonexistant place
          @edit=true
          render 'edit'
       end


       @place.update(place_params)

       convert_location_params()

       #timestanps
       @place.updated_at = Time.new()

       @place_instance=PlaceInstance.new(@place.attributes)
       #do not inherit id from parent ... use NIL to creat our own
       @place_instance.id=nil

       if @place.save
         @place_instance.place_id=@place.id
         if @place_instance.save
           flash[:success] = "Updated place, id:"+@place.id.to_s
           show()
           render 'show'
         else
           # Handle an unsuccessful save.
           flash[:error] = "Error creating instance"
           @edit=true
           render 'edit'
         end
       else
         flash[:error] = "Error saving place"
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
         altArr=Place.find_by_sql ["
            select ST_Value(rast, ST_GeomFromText(?,4326))  id
               from dem100
               where ST_Intersects(rast,ST_GeomFromText(?,4326));",
               'POINT('+params[:location]+')',
               'POINT('+params[:location]+')']
         @place.altitude=altArr.first.try(:id).to_i
       end
    end
  end
end
