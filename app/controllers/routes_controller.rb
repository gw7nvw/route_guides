class RoutesController < ApplicationController

 before_action :signed_in_user, only: [:edit, :update, :new, :create]

def index
    @routes = Route.all.order(:name)
end

  def new
    @edit=true
    @route = Route.new
    @route_types = Routetype.all
    @gradients = Gradient.all
    @alpines = Alpine.all
    @rivers = River.all
    @terrains = Terrain.all
  end

  def create
    @route = Route.new(route_params)
    @route_types = Routetype.all
    @gradients = Gradient.all
    @alpines = Alpine.all
    @rivers = River.all
    @terrains = Terrain.all
    @route.createdBy_id = @current_user.id #current_user.id
    @route_instance=RouteInstance.new(@route.attributes)
    # but doesn;t handle location ... so

    if @route.save
      @route_instance.route_id=@route.id
      if @route_instance.save
        flash[:success] = "New route added, id:"+@route.id.to_s
        redirect_to @route
      else
# Handle a successful save.
#      flash[:error] = "Error creating instance"    
      @edit=true
      render 'new'
      end
    else
#      flash[:error] = "Error creating route"
      @edit=true
      render 'new'
    end
 
  end 

  def show
    @edit=false
    if( @route = Route.find_by_id(params[:id]))
    then
      if(@route.location)
        @route.location=@route.location.as_text
      end
      @route_types = Routetype.all
      @gradients = Gradient.all
      @alpines = Alpine.all
      @rivers = River.all
      @terrains = Terrain.all

    else
      redirect_to root_url
    end
  end

  def edit
    @edit=true
    if( @route = Route.find_by_id(params[:id]))
    then
      if(@route.location) 
         @route.location=@route.location.as_text
      end
      @route_types = Routetype.all
      @gradients = Gradient.all
      @alpines = Alpine.all
      @rivers = River.all
      @terrains = Terrain.all

    else
      redirect_to root_url
    end
  end

  def update
    @route = Route.find_by_id(params[:id])
    @route_types = Routetype.all
    @gradients = Gradient.all
    @alpines = Alpine.all
    @rivers = River.all
    @terrains = Terrain.all
    @route_instance=RouteInstance.new(@route.attributes)
    @route_instance.createdBy_id = @current_user.id #current_user.id
    # but doesn;t handle location ... so

    if @route.update(route_params)
      @route_instance.route_id=@route.id
      @route_instance.id = nil
      if @route_instance.save
        flash[:success] = "Route updated, id:"+@route.id.to_s
        redirect_to @route
      else
# Handle a successful save.
#      flash[:error] = "Error creating instance"    
      @edit=true
      render 'edit'
      end
    else
#      flash[:error] = "Error creating route"
      @edit=true
      render 'edit'
    end

end

  private
  def route_params
    params.require(:route).permit(
       :name, 
       :description,        
       :routetype_id,
       :gradient_id,
       :terrain_id,
       :alpinesummer_id,
       :river_id,
       :alpinewinter_id,
       :winterdescription,
       :startplace_id,
       :endplace_id,
       :links,
       :location)
  end

end
