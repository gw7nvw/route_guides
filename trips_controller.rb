class TripsController < ApplicationController
require "rexml/document"
 before_action :signed_in_user, only: [:new, :create]
 before_action :touch_user


def index
  if signed_in?  then 
      if @current_user.role.name=="root" then
        whereclause="true"
      else
        whereclause='("createdBy_id" = '+@current_user.id.to_s+' or published = true)'
      end
  else 
      if is_guest? then
        whereclause='(id = '+@current_guest.currenttrip_id.to_s+' or published = true)'
      else
        whereclause='published = true'
      end
  end

  @searchtext=params[:searchtext]
   if params[:searchtext] then
      whereclause=whereclause+" and lower(name) like '%%"+@searchtext.downcase+"%%'"
   end

   @trips=Trip.where(whereclause)
   if params[:order]=='latest' then
     @trips=@trips.order('updated_at desc')
     @order='latest'
   else
     @trips=@trips.order('name')
   end
   @count=@trips.count
   @trips=@trips.paginate(:per_page => 20, :page => params[:page])
   @referring_page="index"
end

def wishlist
   current_user()
   current_guest()

   whereclause='true'
   if (signed_in?) then whereclause='"createdBy_id" = '+@current_user.id.to_s end
   if (is_guest?) then whereclause='"id" = '+@current_guest.currenttrip_id.to_s end

   @searchtext=params[:searchtext]
   if params[:searchtext] then
      whereclause=whereclause+" and lower(name) like '%%"+@searchtext.downcase+"%%'"
   end

   @trips=Trip.where(whereclause)
   if params[:order]=='latest' then
     @trips=@trips.order('updated_at desc')
     @order='latest'
   else
     @trips=@trips.order('name')
   end
   @count=@trips.count
   @trips=@trips.paginate(:per_page => 20, :page => params[:page])

  @referring_page="wishlist"
  render 'index'
end

def currenttrip
  current_user()

  if signed_in? then 
    params[:id]=@current_user.currenttrip_id
  else 
    if is_guest? then params[:id]=@current_guest.currenttrip_id end
  end

  if params[:id] then  
    show()
    @trip=Trip.find_by_id(params[:id])
    #render 'show'
  else
      redirect_to root_path
  end
end

def move
 #do stuff from edit page with page
 if params[:selected_id] then
    @id=params[:selected_id]
 else
    @id=params[:id] 
 end

 if @id then @trip=Trip.find_by_id(@id) end
 if @trip then 
  prepare_route_vars()
  @referring_page=params[:referring_page]
  if !@referring_page or @referring_page.length==0 then @referring_page='index' end
  if @trip and ((signed_in? and (@trip.createdBy_id==@current_user.id or @current_user.role.name=="root")) or (is_guest? and @id.to_i==@current_guest.currenttrip_id))
    @edit=true
   
    @place_types = PlaceType.all
 
    
    if (params[:commit])  
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
      if (params[:commit][0..6] == 'reverse')
        td_id=params[:commit][7..-1]
        trip_details=TripDetail.find_by_id(td_id)
        if (trip_details)
           trip_details.route_id=-trip_details.route_id
           trip_details.save
           flash[:success] = "Reversed direction of specified route in this trip"
        else
           flash[:error] = "Cannot find item to reverse:"+params[:cutFrom]
        end
      end

      if (params[:commit][0..4] == 'paste')
         thistrip_details=TripDetail.find_by_id(params[:cutFrom])
         above_id=params[:commit][5..-1]
         order=1
         logger.debug above_id
         trip_details=TripDetail.where(trip_id: @id).order(:order)
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
     end
   end

   #do stuff from index with a row
   if params[:selected_id] then index=true end

   #user only - selct new trip
   if params[:selected_id] and signed_in?  then
     if (params[:commit] == 'Select as current')
          #@trip=Trip.find_by_id(params[:selected_id])
   
          if @trip.createdBy_id==@current_user.id or @current_user.role.name=="root" 
            @current_user.currenttrip_id = @trip.id
            @current_user.save
          end  
          index=true
     end
   end

   #guest and used ...
   if params[:selected_id] and (signed_in? or is_guest?)

     if (params[:commit] == 'Delete')
          trip=@trip
          if trip and ((signed_in? and (trip.createdBy_id==@current_user.id or @current_user.role.name=="root")) or (is_guest? and @current_guest.currenttrip_id==trip.id)) then
    
            # if we delete current trip of any user, selct first remainingtrip as current, or else make a new one ...
            affectedUsers=User.find_by_sql [ "select * from users where currenttrip_id=?", trip.id ]
            affectedUsers.each do |u|
                trips=Trip.where('"createdBy_id" = ? and "id" <> ?',u.id, trip.id).order(:name)
                if trips.count>0 then 
                  @trip=trips.first 
                else
                  @trip=Trip.new()
                  @trip.createdBy_id=u.id
                  @trip.name="Default" 
                  @trip.save
                end
                u.currenttrip_id = @trip.id
                u.save
                if signed_in? and @current_user.id=u.id then @current_user.reload end
            end     
            #affectedGuests ...
            affectedGuests=Guest.find_by_sql [ "select * from guests where currenttrip_id=?", trip.id ]
            affectedGuests.each do |u|
                  @trip=Trip.new()
                  @trip.name="My Trip"
                  @trip.save
                  u.currenttrip_id = @trip.id
                  u.save
                if is_guest? and @current_guest.id=u.id then @current_guest.reload end
            end

            if trip.destroy_tree then
              flash[:success]="Trip deleted"
            else
              flash[:error]="Error: falied to delete trip"
            end
          else
            flash[:error]="Error: You cannot delete this trip"
          end
          index=true
     end

   #copy someone elses trip
       if (params[:commit] and params[:commit] == 'Make my own copy')
          old_trip=@trip
          if is_guest? then
            @current_guest.currenttrip.destroy_tree
          end
          @trip= old_trip.dup
          if signed_in?
            @trip.createdBy_id=@current_user.id
            @trip.name = @current_user.name+"'s copy of "+@trip.name
          else
            @trip.name = "My Trip"
          end
          @trip.published=false
          @trip.save
          @id=params[:id]=@trip.id
          old_trip.trip_details.each do |td|
             new_td=td.dup
             new_td.trip_id=@trip.id
             new_td.save
          end

          if signed_in?
            @current_user.currenttrip_id = @trip.id
            @current_user.save
          else
            @current_guest.currenttrip_id = @trip.id
            @current_guest.save
          end
       end
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
 else #if !@trip
   redirect_to '/trips/'
 end
end


def new
  @trip=Trip.new()
  @trip.createdBy_id=@current_user.id
  @trip.name="Default"
  @trip.save
  flash[:success]="New trip created and assigned as your current trip"
  user=User.find_by_id(@current_user.id)
  user.currenttrip_id = @trip.id
  user.save

  prepare_route_vars()
  @place_types = PlaceType.all
  @edit=true

  render 'show'

end

def show
  @edittrippage=true if @edit
  if params[:editlinks] then @editlinks=true end
  if !@trip then @trip=Trip.find_by_id(params[:id]) end 
  if !@trip then
    redirect_to '/trips'
  else
    prepare_route_vars()
    @place_types = PlaceType.all
    @referring_page='/trips/'+@trip.id.to_s
   
    respond_to do |wants|
      wants.js do
          render '/trips/show'
      end
      wants.html do
          render '/trips/show'
      end
      wants.gpx do
        if(@trip.startplace and @trip.endplace)
          routes=[] 
          @trip.trip_details.each do |item|
             if item.route_id and item.route_id!=0 then routes=routes+[Route.find_by_signed_id(item.route_id)] end
          end
  
          xml = route_to_gpx(routes)
          response.headers['Content-Disposition'] = 'attachment; filename=' + (@trip.name).gsub(/[\\\/\s]/, '_') + '.gpx'
          render :xml => xml
        end
      end
    end 
  end
end

def edit

  @trip=Trip.find_by_id(params[:id]) if !@trip
  if @trip then
    prepare_route_vars()
    @place_types = PlaceType.all
    
    if (signed_in? and (@trip.createdBy_id==@current_user.id or @current_user.role==Role.find_by( :name => 'root')) or (is_guest? and @trip.id == @current_guest.currenttrip_id))
      @edit=true
        @edittrippage=true
    else
      show()
    end
  else
    redirect_to '/trips'
  end
end

def update 
 if @trip=Trip.find_by_id(params[:id]) then
 
  @edit = true

  if (params[:commit] == "Save") and (signed_in? and (@trip.createdBy_id==@current_user.id or @current_user.role==Role.find_by( :name => 'root')) or (is_guest? and @trip.id == @current_guest.currenttrip_id))
     @trip=Trip.find_by_id(params[:id])
     if params[:trip]['name'] then @trip.name=params[:trip]['name'].strip else @trip.name="" end
     @trip.description=params[:trip]['description']
     if params[:trip]['lengthmin'] then @trip.lengthmin=params[:trip]['lengthmin'].to_f  else @trip.lengthmin=0 end
     if params[:trip]['lengthmax'] then @trip.lengthmax=params[:trip]['lengthmax'].to_f  else @trip.lengthmax=0 end
     if signed_in? then @trip.published=params[:trip]['published'] else @trip.published=false end
     if @trip.save then @edit=false else @edit=true end
  end 

  if (params[:commit] == 'delete') and (signed_in? and (@trip.createdBy_id==@current_user.id or @current_user.role==Role.find_by( :name => 'root')) or (is_guest? and @trip.id == @current_guest.currenttrip_id))

     trip_details=TripDetail.find_by_id(params[:trip]['td'])
     if (trip_details)
        if(trip_details.destroy)
           flash[:success] = "Removed item from trip:"+params[:trip]['td']
        end
     else 
        flash[:error] = "Cannot find item to delete:"+params[:trip]['td']
     end
  end

  if (params[:commit] == 'cut' ) and (signed_in? and (@trip.createdBy_id==@current_user.id or @current_user.role==Role.find_by( :name => 'root')) or (is_guest? and @trip.id == @current_guest.currenttrip_id))
  # implement non-java fallback for cut here.


  end
  if (params[:commit] == 'move') and (signed_in? and (@trip.createdBy_id==@current_user.id or @current_user.role==Role.find_by( :name => 'root')) or (is_guest? and @trip.id == @current_guest.currenttrip_id))
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

   if (params[:commit] == 'Make my own copy') and (signed_in? or is_guest?)
      old_trip=Trip.find_by_id(params[:id])
      if is_guest? then
        @current_guest.currenttrip.destroy_tree
      end
      @trip= old_trip.dup
      if signed_in? 
        @trip.createdBy_id=@current_user.id 
        @trip.name = @current_user.name+"'s copy of "+@trip.name
      else
        @trip.name = "My Trip"
      end
      @trip.save
      params[:id]=@trip.id
      old_trip.trip_details.each do |td|
         new_td=td.dup
         new_td.trip_id=@trip.id
         new_td.save
      end

      if signed_in? 
        @current_user.currenttrip_id = @trip.id
        @current_user.save
      else
        @current_guest.currenttrip_id = @trip.id
        @current_guest.save

      end
   end

   if (params[:commit] == 'Delete') and (signed_in? and (@trip.createdBy_id==@current_user.id or @current_user.role==Role.find_by( :name => 'root')) or (is_guest? and @trip.id == @current_guest.currenttrip_id))
      trip=Trip.find_by_id(params[:id])

      # if we delete current trip, selct first remainingtrip as current, or else make a new one ...
      if signed_in? and trip.id == @current_user.currenttrip_id
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
        @referring_page="wishlist"
      end
      if is_guest? then
          @trip=Trip.new()
          @trip.name="My Trip"
          @trip.save
          @current_guest.currenttrip_id = @trip.id
          @current_guest.save
          @referring_page="currenttrip"
      end

      if trip.destroy_tree then flash[:success]="Trip deleted" end
      index=true
      @edit=false
      if @referring_page=="currenttrip" then
        currenttrip()
      else 
        if @referring_page=="wishlist" then 
          wishlist() 
        else 
          index() 
          render 'index'
        end
      end
   else

      if (params[:commit] == 'edit')
         edit()
         render 'edit' 
      else
         show()
      end
   end
 else #if !@trip
   redirect_to '/trips'
 end
end
end
