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
    @place_types = Place_type.all.order(:name)


    @edit=false
    if( @place = Place.find_by_id(params[:id]))
    then 
      xstr = @place.location.x.to_s
      ystr = @place.location.y.to_s

      @place.location = xstr+" "+ystr

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

    if( !@place = Place.find_by_id(params[:id]))
    #tried to update a nonexistant place
      render 'edit'
    end
    @place.name= place_params[:name]
    @place.description = place_params[:description]
    @place.x = place_params[:x].to_f
    @place.y = place_params[:y].to_f
    @place.projn = place_params[:projn]
    @place.altitude = place_params[:altitude].to_i
    @place.location='POINT('+place_params[:location]+')'
    @place.createdBy_id = current_user.id
    @place.place_type = place_params[:place_type]
    @place.place_owner = place_params[:place_owner]

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
    params.require(:place).permit(:name, :place_type, :place_owner, :description, :location, :altitude, :x, :y, :projn)
  end


end
