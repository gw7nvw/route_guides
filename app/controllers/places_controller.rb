class PlacesController < ApplicationController
 before_action :signed_in_user, only: [:edit, :update, :new, :create]

def new
@edit=true
    @place=Place.new
    @x=1540000
    @y=5370000
    @zoom=512
 
  end

def index
    @places = Place.all
    @x=1540000
    @y=5370000
    @zoom=512

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


    wgs=RGeo::CoordSys::Proj4.new(wgs84_proj4)
    nztm=RGeo::CoordSys::Proj4.new(nztm_proj4)

    xyarr=RGeo::CoordSys::Proj4::transform_coords(wgs,nztm,@place.location.x, @place.location.y)

#    xycoords = RGeo::Feature.cast(@place.location, :factory => nztm_factory, :project => true)
 #   convery location to readable format
    if xyarr.nil? 
    then
       @x=1540000
       @y=5370000
       @zoom=512
    else
      @x=xyarr[0].to_i
      @y=xyarr[1].to_i
      @zoom=1
    end
#    @x=xycoords.x.to_i
#    @y=xycoords.y.to_i
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

  #  xycoords = RGeo::Feature.cast(@place.location, :factory => nztm_factory, :project => true)
  #  @x=xycoords.x.to_i
  #  @y=xycoords.y.to_i
      wgs=RGeo::CoordSys::Proj4.new(wgs84_proj4)
    nztm=RGeo::CoordSys::Proj4.new(nztm_proj4)

    xyarr=RGeo::CoordSys::Proj4::transform_coords(wgs,nztm,@place.location.x, @place.location.y)

#    xycoords = RGeo::Feature.cast(@place.location, :factory => nztm_factory, :project => true)
 #   convery location to readable format
    if xyarr.nil?
    then
       @x=1540000
       @y=5370000
       @zoom=512
    else
      @x=xyarr[0].to_i
      @y=xyarr[1].to_i
      @zoom=1
    end

    @place.location=@x.to_s+" "+@y.to_s
    else
    #place does not exist - return to home
    redirect_to root_url
    end

  end
  
  def update

    if( !@place = Place.find_by_id(params[:id]))
    #tried to update a nonexistant place
      render 'edit'
    end
    @place.name= place_params[:name]
    @place.description = place_params[:description]
    @place.altitude = place_params[:altitude].to_i

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

  def redisplay
      @x=params[:form_x].to_i
      @y=params[:form_y].to_i
#    @x=xycoords.x.to_i
#    @y=xycoords.y.to_i
      @minx=@x-2000
      @miny=@y-1500
      @maxx=@x+2000
      @maxy=@y+1500

  respond_to do |format|
      format.html   { render partial: 'redisplay' }
    end
end  
    
  private 
  def place_params
    params.require(:place).permit(:name, :description, :location, :altitude)
  end


end
