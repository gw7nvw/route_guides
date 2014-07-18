class PlacesController < ApplicationController
 before_action :signed_in_user, only: [:edit, :update, :new, :create]

def new
@edit=true
    @place=Place.new
    @place_types = Place_type.all.order(:name)
  end

def index
    @places = Place.all.order(:name)
end
  def create


    @place = Place.new(place_params)

    x=place_params[:x].to_f
    y=place_params[:y].to_f

    @place.location='POINT('+place_params[:location]+')'
    @place.createdBy_id = @current_user.id #current_user.id

    @place_instance=PlaceInstance.new(@place.attributes)
    # but doesn;t handle location ... so

    if @place.save
      @place_instance.place_id=@place.id
      if @place_instance.save     
        flash[:success] = "New place added, id:"+@place.id.to_s
        #refresh variables
        show()

        #render show panel
        render 'show'

      else
# Handle a successful save.
      flash[:error] = "Error creating instance"
      @place_types = Place_type.all.order(:name)
      @edit=true
      render 'new'
      end
    else
      flash[:error] = "Error creating place"
      @place_types = Place_type.all.order(:name)
      @edit=true
      render 'new'
    end
  end

  def show
    @place_types = Place_type.all.order(:name)

    # default visibility 
    @showForward=1
    @showReverse=0
    @showConditions=0
    @showLinks=1

    @edit=false
    if( @place = Place.find_by_id(params[:id]))
    then 
    wgs84_proj4 = '+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs'
    nztm_proj4 = '+proj=tmerc +lat_0=0 +lon_0=173 +k=0.9996 +x_0=1600000 +y_0=10000000 +ellps=GRS80 +towg'

    wgs=RGeo::CoordSys::Proj4.new(wgs84_proj4)
    nztm=RGeo::CoordSys::Proj4.new(nztm_proj4)

    xyarr=RGeo::CoordSys::Proj4::transform_coords(wgs,nztm,@place.location.x, @place.location.y)
    #convery location to readable format
    @x=xyarr[0]
    @y=xyarr[1]

#      xstr = @place.location.x.to_s
#      ystr = @place.location.y.to_s

#      @place.location = xstr+" "+ystr

    #show
    else
    #place does not exist - return to home
    redirect_to root_url
    end    
  
 #   respond_to do |format|
 #       format.js
 #   end

  end

  def edit
    @place_types = Place_type.all.order(:name)
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

    if (params[:save]) 
       if( !@place = Place.find_by_id(params[:id]))
          #tried to update a nonexistant place
          @place_types = Place_type.all.order(:name) 
          @edit=true
          render 'edit'
       end
    
       @place.name= place_params[:name]
       @place.description = place_params[:description]
       @place.x = place_params[:x].to_f
       @place.y = place_params[:y].to_f
       @place.projn = place_params[:projn]
       @place.altitude = place_params[:altitude].to_i
       @place.location='POINT('+place_params[:location]+')'
       @place.createdBy_id = @current_user.id
       @place.place_type = place_params[:place_type]
       @place.place_owner = place_params[:place_owner]
       @place.links = place_params[:links]
       @place.updated_at = Time.new()

       @place_instance=PlaceInstance.new(@place.attributes)


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
           @place_types = Place_type.all.order(:name)
           render 'edit'
         end
       else
         flash[:error] = "Error saving place"
         @edit=true
         @place_types = Place_type.all.order(:name)
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
    params.require(:place).permit(:name, :place_type, :place_owner, :description, :location, :altitude, :x, :y, :projn, :links)
  end


end
