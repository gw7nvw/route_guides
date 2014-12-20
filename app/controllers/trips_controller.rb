class TripsController < ApplicationController
 before_action :signed_in_user, only: [:edit, :update, :new, :create, :move, :wishlish]
 before_action :touch_user


def index
  if signed_in?  then @trips=Trip.where('"createdBy_id" = ? or published = true ',@current_user.id).order(:name)
  else @trips=Trip.where(published: true).order(:name) 
  end
  @referring_page="index"
end

def wishlist
  current_user()

  @trips=Trip.where('"createdBy_id" = ?',@current_user.id).order(:name)

  @referring_page="wishlist"
  render 'index'
end

def currenttrip
  current_user()

  params[:id]=@current_user.currenttrip_id
  show()
  @trip=Trip.find_by_id(@current_user.currenttrip_id)

  render 'show'
end

def move
   @edit=true
   @referring_page=params[:referring_page]
   if !@referring_page or @referring_page.length==0 then @referring_page='index' end
  
      prepare_route_vars()
      @place_types = PlaceType.all

   @trip=Trip.find_by_id(params[:id])

  if (params[:commit][0..5] == 'delete')
     trip_details=TripDetail.find_by_id(params[:cutFrom])
     if (trip_details)
        if(trip_details.destroy)
           flash[:success] = "Removed item from trip:"+params[:cutFrom]
        end
     else
        flash[:error] = "Cannot find item to delete:"+params[:cutFrom]
     end
  end
  if (params[:commit][0..4] == 'paste')
     thistrip_details=TripDetail.find_by_id(params[:cutFrom])
     above_id=params[:commit][5..-1]
     order=1
     logger.debug above_id
     trip_details=TripDetail.where(trip_id: params[:id]).order(:order)
     trip_details.each do |td|
       if td.id == above_id.to_i then
         thistrip_details.order=order
         thistrip_details.save
         order=order+1
       end
       if td.id != thistrip_details.id then
         td.order=order
         td.save
         order=order+1
       end
     end
     # if we pasted at bottom
     if above_id=="" then
         thistrip_details.order=order
         thistrip_details.save
     end
  end

   if (params[:commit] == 'Select as current')
      @trip=Trip.find_by_id(params[:selected_id])

      @current_user.currenttrip_id = @trip.id
      @current_user.save

      index=true
   end

   if (params[:commit] == 'Make my own copy')
      old_trip=Trip.find_by_id(params[:selected_id])
      @trip= old_trip.dup
      @trip.createdBy_id=@current_user.id 
      @trip.name = @current_user.name+"'s copy of "+@trip.name
      @trip.save

      old_trip.trip_details.each do |td|
         new_td=td.dup
         new_td.trip_id=@trip.id
         new_td.save
      end

      @current_user.currenttrip_id = @trip.id
      @current_user.save
   end

   if (params[:commit] == 'Delete')
      trip=Trip.find_by_id(params[:selected_id])

      # if we delete current trip, selct first remainingtrip as current, or else make a new one ...
      if trip.id == @current_user.currenttrip_id
        trips=Trip.where('"createdBy_id" = ? and "id" <> ?',@current_user.id, trip.id).order(:name)
        if trips.count>0 then 
          @trip=trips.first 
        else
          @trip=Trip.new()
          @trip.createdBy_id=@current_user.id
          @trip.name="Default" 
          @trip.save
        end
        @current_user.currenttrip_id = @trip.id
        @current_user.save
      end

      links=trip.links
      links.each do |l|
         l.destroy
      end

      trip.destroy
      index=true
      @referring_page="wishlist"
   end

   if index==true 
      if @referring_page=="wishlist" then 
        wishlist() 
      else 
        index() 
        render 'index'
      end
   else
      render 'show'
   end
end


def new
  @trip=Trip.new()
  @trip.createdBy_id=@current_user.id
  @trip.name="Default"
  @trip.save
  user=User.find_by_id(@current_user.id)
  user.currenttrip_id = @trip.id
  user.save

  prepare_route_vars()
  @place_types = PlaceType.all
  @edit=true

  render 'show'

end

def show
    if params[:editlinks] then @editlinks=true end

  if !@trip=Trip.find_by_id(params[:id]) then
    redirect_to root_url
  end
  prepare_route_vars()
  @place_types = PlaceType.all
  @referring_page='/trips/'+@trip.id.to_s
  
end

def edit
  @trip=Trip.find_by_id(params[:id])
  if ((@trip.createdBy_id!=@current_user.id) and (@current_user.role!=Role.find_by( :name => 'root')))
    show()
    render 'show'
  end

  prepare_route_vars()
  @place_types = PlaceType.all
  @edit=true
end

def update 
  @edit = true

  if (params[:commit] == "Save")
     @trip=Trip.find_by_id(params[:id])
     @trip.name=params[:trip]['name']
     @trip.description=params[:trip]['description']
     @trip.lengthmin=params[:trip]['lengthmin'].to_f
     @trip.lengthmax=params[:trip]['lengthmax'].to_f
     @trip.published=params[:trip]['published']
     @trip.save
     @edit=false
  end 

  if (params[:commit] == 'delete')
     trip_details=TripDetail.find_by_id(params[:trip]['td'])
     if (trip_details)
        if(trip_details.destroy)
           flash[:success] = "Removed item from trip:"+params[:trip]['td']
        end
     else 
        flash[:error] = "Cannot find item to delete:"+params[:trip]['td']
     end
  end

  if (params[:commit] == 'cut' )
  # implement non-java fallback for cut here.


  end
  if (params[:commit] == 'move')
     thistrip_details=TripDetail.find_by_id(params[:moveForm]['cutFrom'])
     above_id=params[:moveForm]['pasteBelow']
     order=1
     trip_details=TripDetail.find_by(:trip_id => params[:id]).order(:order)
     # loop through all items, reordering, and insert above the requested slot
     trip_details.each do |td|
       if td.id == above_id then
         thistrip_details.order=order
         thistrip_details.save
         order=order+1
       end 
       if td.id != thistrip_details.id then
         td.order=order
         td.save
       end
       order=order+1
     end 
     # and handle paste below all
     if above_id=="" then 
         thistrip_details.order=1
         thistrip_details.save
     end
  end

   if (params[:commit] == 'Make my own copy')
      old_trip=Trip.find_by_id(params[:id])
      @trip= old_trip.dup
      @trip.createdBy_id=@current_user.id
      @trip.name = @current_user.name+"'s copy of "+@trip.name
      @trip.save
      params[:id]=@trip.id
      old_trip.trip_details.each do |td|
         new_td=td.dup
         new_td.trip_id=@trip.id
         new_td.save
      end

      @current_user.currenttrip_id = @trip.id
      @current_user.save
   end

   if (params[:commit] == 'Delete')
      trip=Trip.find_by_id(params[:id])

      # if we delete current trip, selct first remainingtrip as current, or else make a new one ...
      if trip.id == @current_user.currenttrip_id
        trips=Trip.where('"createdBy_id" = ? and "id" <> ?',@current_user.id, trip.id).order(:name)
        if trips.count>0 then
          @trip=trips.first
        else
          @trip=Trip.new()
          @trip.createdBy_id=@current_user.id
          @trip.name="Default"
          @trip.save
        end
        @current_user.currenttrip_id = @trip.id
        @current_user.save
      end

      links=trip.links
      links.each do |l|
         l.destroy
      end

      trip.destroy
      index=true
      @referring_page="wishlist"

      if @referring_page=="wishlist" then 
        wishlist() 
      else 
        index() 
        render 'index'
      end
   else

      if (params[:commit] == 'edit')
         edit()
         render 'edit' 
      else
         show()
         render 'show'
      end
   end
end
end
