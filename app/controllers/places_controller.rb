class PlacesController < ApplicationController
before_action :signed_in_user, only: [:edit, :update, :new, :create]

def new
    @edit=true
    @place=Place.new
  
  end

def index
    @places = Place.all
end
  def create


    @place = Place.new(place_params)

    x=place_params[:location].to_s.split(' ')[0].to_f
    y=place_params[:location].to_s.split(' ')[1].to_f
    wgs=RGeo::CoordSys::Proj4.new(wgs84_proj4)
    nztm=RGeo::CoordSys::Proj4.new(nztm_proj4)

    xyarr=RGeo::CoordSys::Proj4::transform_coords(nztm,wgs,x, y)

    @place.location='POINT('+xyarr[0].to_s+" "+xyarr[1].to_s+')'
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


    @edit=false
    if( @place = Place.find_by_id(params[:id]))
    then 
    #show


#    wgs=RGeo::CoordSys::Proj4.new(wgs84_proj4)
#    nztm=RGeo::CoordSys::Proj4.new(nztm_proj4)

#    xyarr=RGeo::CoordSys::Proj4::transform_coords(wgs,nztm,@place.location.x, @place.location.y)

    xycoords = RGeo::Feature.cast(@place.location, :factory => nztm_factory, :project => true)
#    convery location to readable format
#    if xyarr.nil? 
#    then
#       @x=0
#       @y=0
#    else
#      @x=xyarr[0]
#      @y=xyarr[1]
#    end
    @x=xycoords.x
    @y=xycoords.y
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

    xycoords = RGeo::Feature.cast(@place.location, :factory => nztm_factory, :project => true)
    @x=xycoords.x
    @y=xycoords.y
    @map_extent=(@x-2000).to_s+" "+(@y-1000).to_s+" "+(@x+2000).to_s+" "+(@y+1000).to_s
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

    x=place_params[:location].to_s.split(' ')[0].to_f
    y=place_params[:location].to_s.split(' ')[1].to_f
    wgs=RGeo::CoordSys::Proj4.new(wgs84_proj4)
    nztm=RGeo::CoordSys::Proj4.new(nztm_proj4)

    xyarr=RGeo::CoordSys::Proj4::transform_coords(nztm,wgs,x, y)

    @place.location='POINT('+xyarr[0].to_s+" "+xyarr[1].to_s+')'
    @place.createdBy_id = current_user.id

    @place_instance=PlaceInstance.new(@place.attributes)
    # but doesn;t handle location ... so


    @place_instance.id=nil

    if @place.save
      @place_instance.place_id=@place.id
      if @place_instance.save
        flash[:success] = "Updated place, id:"+@place.id.to_s
        redirect_to @place
      else
# Handle a successful save.
      flash[:error] = "Error creating instance"

      render 'new'
      end
    else
      flash[:error] = "Error saving place"

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
