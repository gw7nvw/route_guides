class TripsController < ApplicationController
 before_action :signed_in_user, only: [:edit, :update, :new, :create]

def index
  @trips=Trip.all.order(:id)
end

def show
  @trip=Trip.find_by_id(params[:id])
      @route_types = Routetype.all
      @gradients = Gradient.all
      @alpines = Alpine.all
      @rivers = River.all
      @terrains = Terrain.all
      @place_types = Place_type.all
end

def edit
  @trip=Trip.find_by_id(params[:id])
  if ((@trip.createdBy_id!=@current_user.id) and (@current_user.role!=Role.find_by( :name => 'root')))
    show()
    render 'show'
  end

  @route_types = Routetype.all
  @gradients = Gradient.all
  @alpines = Alpine.all
  @rivers = River.all
  @terrains = Terrain.all
  @place_types = Place_type.all
  @edit=true
end

def update 
  @edit = true

  if (params[:commit] == "Save")
     @trip=Trip.find_by_id(params[:id])
     @trip.name=params[:trip]['name']
     @trip.description=params[:trip]['description']
     @trip.save
     @edit=false
  end 

  if (params[:commit] == 'X')
     trip_details=TripDetail.find_by_id(params[:trip]['td'])
     if (trip_details)
        if(trip_details.destroy)
           flash[:success] = "Removed item from trip:"+params[:trip]['td']
        end
     else 
        flash[:error] = "Cannot find item to delete:"+params[:trip]['td']
     end
  end

  if (params[:commit] == 'up')
     td=TripDetail.find_by_id(params[:trip]['td'])
     prev_td=TripDetail.where(trip_id: td.trip_id).where('"order" < ?',td.order).order(:order).last()

     if (td and prev_td)
        temp=td.order
        td.order=prev_td.order
        prev_td.order=temp
        td.save
        prev_td.save 
     end
  end

  if (params[:commit] == 'down')
     td=TripDetail.find_by_id(params[:trip]['td'])
     next_td=TripDetail.where(trip_id: td.trip_id).where('"order" > ?',td.order).order(:order).first()

     if (td and next_td)
        temp=td.order
        td.order=next_td.order
        next_td.order=temp
        td.save
        next_td.save
     end
  end

  if (params[:commit] == 'top')
     td=TripDetail.find_by_id(params[:trip]['td'])
     first_td=TripDetail.where(trip_id: td.trip_id).order(:order).first()

     if (td and first_td)
        td.order=first_td.order-1
        td.save
     end
  end

  if (params[:commit] == 'bottom')
     td=TripDetail.find_by_id(params[:trip]['td'])
     last_td=TripDetail.where(trip_id: td.trip_id).order(:order).last()

     if (td and last_td)
        td.order=last_td.order+1
        td.save
     end
  end

  if (params[:commit] == 'edit')
     edit()
     render 'edit' 
  else
     show()
     render 'show'
  end
end
end
