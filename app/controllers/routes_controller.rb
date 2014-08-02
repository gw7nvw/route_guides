class RoutesController < ApplicationController

#get altitude from DEM if not set
 before_action :signed_in_user, only: [:edit, :update, :new, :create]

  def index
    @routes = Route.all.order(:name)
  end

  def search
     @trip=true
     prepare_route_vars()

  end

  def find
     @trip=true
     @route_ids=routes_from_to(params[:route_startplace_id].to_i, params[:route_endplace_id].to_i)
     prepare_route_vars()

     render 'search'
  end

  def new
    @edit=true
    @route = Route.new
    prepare_route_vars()
  end

  def create
    @route = Route.new(route_params)    
    prepare_route_vars()
    @route.createdBy_id = @current_user.id #current_user.id
    @route_instance=RouteInstance.new(@route.attributes)
    # but doesn;t handle location ... so

    if @route.save
      @route_instance.route_id=@route.id
      if @route_instance.save
        flash[:success] = "New route added, id:"+@route.id.to_s

        @edit=false
        @showForward=1
        @showReverse=1
        @showConditions=1
        @showLinks=1

        render 'show'

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

    # default visibility 
    @showForward=1
    @showReverse=1
    @showConditions=1
    @showLinks=1

    if( @route = Route.find_by_id(params[:id]))
    then
      if(@route.location)
        @route.location=@route.location.as_text
      end
      prepare_route_vars()

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
      prepare_route_vars()
    else
      redirect_to root_url
    end
  end

  def update
    @route = Route.find_by_id(params[:id])
    logger.debug params[:id]

    add=false
    if (params[:addfw])
      @trip=Trip.find_by_id(@current_user.currenttrip)
      @trip_details = TripDetail.new
      @trip_details.showForward=true;
      @trip_details.showReverse=false;
      @trip_details.is_reverse=false
      add=true
    end

    if (params[:addrv])
      @trip=Trip.find_by_id(@current_user.currenttrip)
      @trip_details = TripDetail.new
      #for reverse trips, show the reverse directions if present, or the f/w ones if not
      if (@route.reverse_description and @route.reverse_description.length>0) then
        @trip_details.showForward=true;
        @trip_details.showReverse=false;
      else
        @trip_details.showForward=false;
        @trip_details.showReverse=true;
      end
      @trip_details.is_reverse=true
      add=true
    end

    if (add)
      @trip_details.trip = @trip
      @trip_details.route_id = params[:id]
      @trip_details.showConditions=false;
      @trip_details.showLinks=false;

      if(@trip.trip_details.max)
        @trip_details.order = @trip.trip_details.max.id+1
      else
        @trip_details.order = 1
      end
      @trip_details.save
      flash[:success]="Added route to trip"

#      params[:id]=@trip.id
      show()
      render 'show'
    end

    if (params[:save])

      @route.updated_at=Time.new()
      prepare_route_vars()

 
      @route_instance=RouteInstance.new(@route.attributes)
      @route_instance.createdBy_id = @current_user.id #current_user.id
      # but doesn;t handle location ... so

      if @route.update(route_params)
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
               altArr=Place.find_by_sql ["
                  select ST_Value(rast, ST_GeomFromText(?,4326))  id
                     from dem100
                     where ST_Intersects(rast,ST_GeomFromText(?,4326));",
                     'POINT('+p.x.to_s+' '+p.y.to_s+')',
                     'POINT('+p.x.to_s+' '+p.y.to_s+')']

               linestr+=p.x.to_s+" "+p.y.to_s+" "+altArr.first.try(:id).to_s
            end
            @route.location=linestr+")"
            @route.save
        end
        @route_instance.route_id=@route.id
        @route_instance.id = nil
        if @route_instance.save
          flash[:success] = "Route updated, id:"+@route.id.to_s
          show()
          render 'show'

        else
          flash[:error] = "Error creating instance"    
          @edit=true
          render 'edit'
        end
      else
        flash[:error] = "Error creating route"
        @edit=true
        render 'edit'
      end
    end
  

    if (params[:delete])
    
      if(!trip=TripDetail.find_by(:route_id => params[:id])) 
   
        route=Route.find_by_id(params[:id])
        if route.destroy
          flash[:success] = "Route deleted, id:"+params[:id]
          redirect_to '/routes'
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

  def routes_from_to(placea, placeb)
  maxLegCount=20

  if (here=Place.find_by_id(placea))
  validDest=Array.new
  placeSoFar=[]
  routeSoFar=[]
  placeSoFar[0]=[here.id]
  routeSoFar[0]=[]
  goodPath=[]
  goodRoute=[]
  destFound=1
  legCount=0
  goodPathCount=0

  while destFound>0 and legCount<maxLegCount do

    legCount+=1
    loopCount=0
    nextPlaceSoFar=[]
    nextRouteSoFar=[]
    placeSoFar.each do |thisPath|

      #get latets place added to list
      here=Place.find_by_id(thisPath[0])
      destFound=0

      #add each route to hash
      here.adjoiningRoutes.each do |ar|
        if ar.endplace_id==here.id then nextDest=ar.startplace_id
        else nextDest=ar.endplace_id
        end

        if nextDest==placeb then
                goodPath[goodPathCount]=[nextDest]+thisPath
                goodRoute[goodPathCount]=[ar.id]+routeSoFar[loopCount]
                goodPathCount+=1
        else
          if !thisPath.include? nextDest then
                nextRouteSoFar[destFound]=[ar.id]+routeSoFar[loopCount]
                nextPlaceSoFar[destFound]=[nextDest]+thisPath
                destFound+=1
          end
        end
      end #end of 'each adjoining route' for thisPlace
      loopCount+=1
    end # end of for each flace so far
    #replace placesSpFar with new list of latest destinatons found
    placeSoFar=nextPlaceSoFar
    routeSoFar=nextRouteSoFar
  end #end of while we get results & don;t exceed max hop count

  goodRoute
  end

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
       :datasource)
  end

end
