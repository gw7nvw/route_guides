class PlacesController < ApplicationController
before_action :signed_in_user
def new
    @edit=true
    @place=Place.new
  
  end

  def create
    @place = Place.new(place_params)

    @place.location='POINT('+place_params[:location].to_s+')'
    @place.createdBy_id = 1 #current_user.id

    @place_instance=PlaceInstance.new(@place.attributes)
    # but doesn;t handle location ... so

    if @place.save
      @place_instance.place_id=@place.id
      if @place_instance.save     
        flash[:success] = "New place added, id:"+@place.id.to_s
        redirect_to @place
      else
# Handle a successful save.
      flash[:error] = "Error creating instance"

      render 'new'
      end
    else
      flash[:error] = "Error creating place"
    
      render 'new'
    end
  end

  def show
wgs84_proj4 = '+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs'


nztm_proj4 = '+proj=tmerc +lat_0=0 +lon_0=173 +k=0.9996 +x_0=1600000 +y_0=10000000 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs'



    @edit=false
    if( @place = Place.find_by_id(params[:id]))
    then 
    #show


    wgs=RGeo::CoordSys::Proj4.new(wgs84_proj4)
    nztm=RGeo::CoordSys::Proj4.new(nztm_proj4)

    xyarr=RGeo::CoordSys::Proj4::transform_coords(wgs,nztm,@place.location.x, @place.location.y)
    #convery location to readable format
    @x=xyarr[0]
    @y=xyarr[1]
    @map_extent=(@x-2000).to_s+" "+(@y-1000).to_s+" "+(@x+2000).to_s+" "+(@y+1000).to_s
    @place.location=@x.to_s+" "+@y.to_s
    else
    #place does not exist - return to home
    redirect_to root_url
    end    
  end

  def edit
    @edit=true
    if( @place = Place.find_by_id(params[:id]))
    #show

    #convery location to readable format
    @x = @place.location.x
    @y = @place.location.y
    @place.location=@x.to_s+" "+@y.to_s
    else
    #place does not exist - return to home
    redirect_to root_url
    end    
  end
  
  def update
    @place = Place.new(place_params)
    if( !@place = Place.find_by_id(params[:id]))
    #tried to update a nonexistant place
      render 'edit'
    end

    @place.location='POINT('+place_params[:location].to_s+')'
    @place.createdBy_id = current_user.id

    @place_instance=PlaceInstance.new(@place.attributes)
    # but doesn;t handle location ... so

    if @place.save
      @place_instance.place_id=@place.id
      if @place_instance.save
        flash[:success] = "New place added, id:"+@place.id.to_s
        redirect_to @place
      else
# Handle a successful save.
      flash[:error] = "Error creating instance"

      render 'new'
      end
    else
      flash[:error] = "Error creating place"

      render 'new'
    end

  end

  def destroy
  end

  private 
  def place_params
    params.require(:place).permit(:name, :description, :location, :altitude)
  end
end
