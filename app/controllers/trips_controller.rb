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
  @showcurrenttrip=true

  if signed_in? then 
    params[:id]=@current_user.currenttrip_id
  else 
    if is_guest? then params[:id]=@current_guest.currenttrip_id end
  end

  if params[:id] and params[:id].to_s.length>0 then 
    show()
    @trip=Trip.find_by_id(params[:id])
    return
  end
  render 'show'
end

def delete
  trip=Trip.find(params[:id])
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
      if (params[:commit][0..5] == 'Delete')
        trip_details=TripDetail.find_by_id(params[:pasteAfter])
        if (trip_details)
           if(trip_details.destroy)
              flash[:success] = "Removed item from trip:"+params[:pasteAfter]
           end
        else
           flash[:error] = "Cannot find item to delete:"+params[:pasteAfter]
        end
      end
      if (params[:commit][0..6] == 'Reverse')
        td_id=params[:pasteAfter]
        trip_details=TripDetail.find_by_id(td_id)
        if (trip_details)
           trip_details.route_id=-trip_details.route_id
           trip_details.save
           flash[:success] = "Reversed direction of specified route in this trip"
        else
           flash[:error] = "Cannot find item to reverse:"+params[:cutFrom]
        end
      end

      if (params[:commit][0..4] == '-----')
         above_id=params[:pasteAfter]
         thistrip_details=TripDetail.find_by_id(params[:cutFrom])
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
         flash[:success] = "Moved segment of this trip"
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

    end
    if index==true 
      if @referring_page=="wishlist" then 
        wishlist() 
      else 
        index() 
        render 'index'
      end
    else
      render 'move'
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
    if (signed_in? and @current_user.currenttrip_id==@trip.id) or (is_guest? and @current_guest.currenttrip_id==@trip.id) then    
       @showcurrenttrip=true
    else 
       @showcurrenttrip=false
    end 

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

  if (signed_in? and (@trip.createdBy_id==@current_user.id or @current_user.role==Role.find_by( :name => 'root')) or (is_guest? and @trip.id == @current_guest.currenttrip_id))
     @trip=Trip.find_by_id(params[:id])
     if params[:trip]['name'] then @trip.name=params[:trip]['name'].strip else @trip.name="" end
     @trip.description=params[:trip]['description']
     if params[:trip]['lengthmin'] then @trip.lengthmin=params[:trip]['lengthmin'].to_f  else @trip.lengthmin=0 end
     if params[:trip]['lengthmax'] then @trip.lengthmax=params[:trip]['lengthmax'].to_f  else @trip.lengthmax=0 end
     if signed_in? then @trip.published=params[:trip]['published'] else @trip.published=false end
     if @trip.save then @edit=false else @edit=true end
     show()
  else
    flash[:error]="Error: you are not allowed to modify this trip"
     show()
  end 
 else #if !@trip
   redirect_to '/trips'
 end
end
def copy
    old_trip=Trip.find_by_id(params[:id])
    current_user()
    reload_required=false
    if (!signed_in?) then
      if (!is_guest?) then
        create_guest()
        reload_required=true
      end
    end
    if signed_in? then @trip=Trip.find_by_id(@current_user.currenttrip) end
    if is_guest? then @trip=Trip.find_by_id(@current_guest.currenttrip) end

    @id=params[:id]=@trip.id
    old_trip.trip_details.each do |td|
       new_td=td.dup
       new_td.trip_id=@trip.id
       new_td.save
    end

    flash[:success]="Added route to trip"
    @trip.reload
    prepare_route_vars()
    if reload_required then
       redirect_to '/reload'
    else
      @id=@trip.id
      params[:id]=@trip.id
      show()
    end
end

end
