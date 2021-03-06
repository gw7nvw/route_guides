class RoutesController < ApplicationController
require "rexml/document"

#get altitude from DEM if not set
 before_action :signed_in_user, only: [:edit, :new, :create]
 before_action :touch_user
 
  def leg_index
    @searchtext=params[:searchtext]
    whereclause="true"
    if params[:searchtext] then
       whereclause=whereclause+" and lower(name) like '%%"+@searchtext.downcase+"%%'"
    end

    @routes=Route.where(whereclause)
    if params[:order]=='latest' then
      @routes=@routes.order('updated_at desc')
      @order='latest'
    else
      @routes=@routes.order('name')
    end
    @count=@routes.count
    @routes=@routes.paginate(:per_page => 80, :page => params[:page])
  end

  def index
    route_index = RouteIndex.find_by_sql ["select distinct startplace_id, endplace_id, CONCAT(sp.name, ' to ', ep.name) as url from route_indices inner join places sp on sp.id = startplace_id inner join places ep on ep.id=endplace_id where isdest=true and fromdest=true order by url" ]
#    @routes=route_index.where(:isDest => true, :fromDest => true).sort_by{|a| [a.startplace.name, a.endplace.name]}.paginate(:per_page => 80, :page => params[:page])
    @routes=route_index.paginate(:per_page => 80, :page => params[:page])

  end

  def site_index
    @route_index = RouteIndex.select(:startplace_id, :endplace_id).uniq
    @trips=Trip.where(published: true).order(:name)
    @reports = Report.all.order(:name)
    @places = Place.order(:name)
  end

  def search
     @trip=true
     prepare_route_vars()
     @searchNow=true
     
     if(params[:route_startplace_id] and params[:route_endplace_id]) then find() end

  end

  def find
     @trip=true
     if params[:route_startplace_id] and sp=Place.find_by_id(params[:route_startplace_id]) then
         @startplace=params[:route_startplace_id]
         @startplacename=sp.name
     else
         @startplace=nil
         @startplacename=""
     end
     if params[:route_endplace_id] and ep=Place.find_by_id(params[:route_endplace_id]) then
         @endplace=params[:route_endplace_id]
         @endplacename=ep.name
     else
         @endplace=nil
         @endplacename=""
     end

     placea=Place.find_by_id(params[:route_startplace_id].to_i)
     if placea then
       @route_ids=placea.adjoiningPlacesFast(params[:route_endplace_id].to_i,true,nil,nil,nil)
     else 
       @route_ids=nil
     end 
     prepare_route_vars()

     render 'search'
  end

  def new
    @edit=true
    @route = Route.new
    @route.published=true
    prepare_route_vars()
  end

  def addtrip
    @items=params[:id].split('x')[1..-1]
    current_user()
    if (!signed_in?) then 
      if (!is_guest?) then
        create_guest()
        reload_required=true
      end
    end
    if signed_in? then @trip=Trip.find_by_id(@current_user.currenttrip) end
    if is_guest? then @trip=Trip.find_by_id(@current_guest.currenttrip) end
    @trip.touch
    @items.each do |item|
        itemno=item[2..-1].to_i
        if item[0]=='p' then
          @trip_details = TripDetail.new
          @trip_details.showForward=true;
          @trip_details.is_reverse=false
          @trip_details.trip = @trip
          @trip_details.place_id = itemno
          @trip_details.showConditions=false;
          @trip_details.showLinks=false;
        end
        if item[0]=='r' or item[0]=='q' then
          @trip_details = TripDetail.new
          @trip_details.showForward=true;
          @trip_details.is_reverse=false
          @trip_details.trip = @trip
          @trip_details.route_id = itemno
          @trip_details.showConditions=false;
          @trip_details.showLinks=false;
        end
        if(@trip.trip_details.max)
          @trip_details.order = @trip.trip_details.max.id+1
        else
          @trip_details.order = 1
        end
          @trip_details.save
        flash[:success]="Added route to trip"
    end
    @trip.reload
    prepare_route_vars()
    if reload_required then   
       redirect_to '/reload'
    else
      render '/trips/show'
    end
 end

 def create
    @route = Route.new(route_params)    
    prepare_route_vars()
    @route.createdBy_id = @current_user.id #current_user.id
    @route.updatedBy_id = @current_user.id #current_user.id
    @route.datasource=params[:datasource]
    @url=params[:url]


    # location
    tmploc=params[:route][:location]
    #check num fields
    coordset=tmploc.split('(')[1].split(',')[0]
    coords=coordset.split(' ')
    dims=coords.length
  
    if tmploc[0..12]=="LINESTRING ZM" then
       tmploc='LINESTRING'+tmploc[13..-1] 
    end
    if tmploc[0..11]=="LINESTRING Z" then
       tmploc='LINESTRING'+tmploc[12..-1] 
    end
  
    if dims==4 then   factory=RGeo::Geographic.spherical_factory(:srid => 4326, :has_z_coordinate => true, :has_m_coordinate => true) end
    if dims==3 then   factory=RGeo::Geographic.spherical_factory(:srid => 4326, :has_z_coordinate => true) end
    if dims==2 then   factory=RGeo::Geographic.spherical_factory(:srid => 4326, :has_z_coordinate => false) end
    @route.location=factory.parse_wkt(tmploc)
    route_add_altitude()
  
    dupRoute=Route.find_by_sql ['select * from routes where "startplace_id"=? and "endplace_id"=? and via=?',@route.startplace_id, @route.endplace_id, @route.via]
     logger.debug dupRoute.count
    if dupRoute.count>0  then 
       #save already in procgress
       logger.debug "errorwith 409"
       render nothing: true, status: 409
    else 
      success=@route.save
      if success and !@route.customerrors
        flash[:success] = "New route added, id:"+@route.id.to_s
  

        @edit=false
        @showForward=1
        @showConditions=0
        @showLinks=1
        if @url and @url.include?('x')
          #show routes screen
          #if this is 1st place, next url is select next place.
          #if this s asubsequent place, then next url is create route
          @url=@url.gsub('xrn','xrv'+@route.id.to_s)
          @url=@url+'xps'
          @id=@url
          show_many()
  
          #show the show many screen
          render '/routes/show_many'
        else
          @id=params[:id]=@route.id
          show_single() 
          render 'show'
        end
      else
        flash[:error]=@route.customerrors if @route.customerrors 
        if(@url and @url.include?('x')) then 
           @id=@url
           @editroute=@route
           show_many() 
           render 'routes/show_many'
        else
          @edit=true
          render 'new'
        end
      end
   
    end 
 end

def show
    if params[:editlinks] then @editlinks=true end

    prepare_route_vars()
    routes=[]
    if !@id then @id=params[:id] end
    if @id[0]!="x" then
       show_single()
    else
      show_many()
      if @id.include?('xps') and !signed_in? then 
        redirect_to signin_url+"?referring_url="+URI.escape(request.fullpath), notice: "Please sign in." 

      else
       respond_to do |wants|
        wants.js do
         # if @startplace and @endplace then
            render '/routes/show_many'
         # else
         #   redirect_to root_url
         # end
        end
        wants.html do
         # if @startplace and @endplace then
            render '/routes/show_many'
         # else
         #   redirect_to root_url
         # end
        end
        wants.gpx do
          if(@startplace and @endplace)
            @items.each do |item|
               if item[0]=='r'  or item[0]=='q' then routes=routes+[item[2..-1].to_i] end
            end
            routearr=[]
            routes.each do |r|
              routearr+=[Route.find_by_signed_id(r)]
            end

            xml = route_to_gpx(routearr)
            puts ":"+@startplace.name+"::"+@endplace.name+":"
            response.headers['Content-Disposition'] = 'attachment; filename=' + (@startplace.name+' to '+@endplace.name).gsub(/[\\\/\s\,\(\)]/, '_') + '.gpx'
            render :xml => xml
          end
        end
       end
      end 
    end
end


  def show_single
    @edit=false

    # default visibility 
    @showForward=1
    @showConditions=0
    @showLinks=1

    @route = Route.find_by_signed_id(params[:id])
    if @route then
      @routeInstances=RouteInstance.where(:route_id => @route.id.abs)
      if params[:version] then
        ri=RouteInstance.find_by_id(params[:version])
        if ri.route_id==@route.id then 
          @route.assign_attributes(ri.attributes.except("id", "route_id", "published"))
          if params[:id].to_i<0 then @route.reverse end
          @route.calc_altgain
          @route.calc_altloss
          @route.calc_maxalt
          @route.calc_minalt
          @version=params[:version]
        end
      end
      #followingis slow ... work out why. TODO
      if !@version then  @version=(RouteInstance.find_by_sql [ "select id from route_instances where route_id=? order by updated_at desc limit 1", @route.id.abs.to_s ]).first.try('id') end
    end

      if( @route) then
        if(@route.location)
          flatloc=Route.find_by_sql [ " select ST_AsText(ST_AsEWKT(ST_Force2D(location))) as location from routes where id="+@route.id.abs().to_s ]
          @rtloc=flatloc[0].location
        end
        @referring_page='/routes/'+@route.id.to_s
      else
        redirect_to '/legs'
      end

    respond_to do |wants|
      wants.html do
      end 
      wants.js do
      end 
      wants.gpx do  
        xml = route_to_gpx([@route])
        response.headers['Content-Disposition'] = 'attachment; filename=' + (@route.startplace.name+' to '+@route.endplace.name).gsub(/[\\\/\s\,\(\)]/, '_') + '.gpx'
        render :xml => xml 
      end 
    end 
  end

  def edit
    @edit=true
    if( @route = Route.find_by_signed_id(params[:id]))
    then
      if(@route.location)
          if(@route.location) 
             @route.location=@route.location.as_text
          end
          flatloc=Route.find_by_sql [ " select ST_AsText(ST_AsEWKT(ST_Force2D(location))) as location from routes where id="+@route.id.abs().to_s ]
          @rtloc=flatloc[0].location
        end

      @route.experienced_at=nil if @current_user!=@route.updatedBy
      prepare_route_vars()
    else
      redirect_to '/legs'
    end
  end

  def update
    @route = Route.find_by_signed_id(params[:id])
    logger.debug params[:id]

    add=false
    if (params[:addfw])
      route=@route
      add=true
    end

    if (params[:addrv])
      route=@route.reverse
      add=true
    end

    if (add)
        if (!signed_in?) then 
          if (!is_guest?) then
            create_guest()
            reload_required=true
          end
        end
        if is_guest? then trip=Trip.find_by_id(@current_guest.currenttrip) end
        if signed_in? then trip=Trip.find_by_id(@current_user.currenttrip) end
        trip_details = TripDetail.new
        trip_details.showForward=true;
        trip_details.trip_id = trip.id
        trip_details.route_id = route.id
        trip_details.showConditions=false;
        trip_details.showLinks=false;
  
        if(trip.trip_details.max)
          trip_details.order = trip.trip_details.max.id+1
        else
          trip_details.order = 1
        end
        trip_details.save
        flash[:success]="Added route to trip"
  
        @trip= trip.reload
        params[:id]=@trip.id
        prepare_route_vars()
        if reload_required then
          redirect_to '/reload'
        else
          render '/trips/show'
        end

    end

    if (params[:save])
     if (!signed_in?) then 
       redirect_to signin_url+"?referring_url="+URI.escape(request.fullpath), notice: "Please sign in." 
     else
       @url=params[:url]||""
       @viewurl=@url.gsub('xrn','xrv'+@route.id.to_s)
       if @viewurl.include?('xrm') then 
         @viewurl=@viewurl.gsub('xrv','xre').gsub('xrm','xrv') 
         @editmany=true
       else
         @editmany=false
         #if we added new, then next step is select next place 
         if @url.include?('xrn') then @viewurl=@viewurl+'xps' end
         @viewurl=@viewurl.tr("e","v")
       end

      prepare_route_vars()

      # but doesn;t handle location ... so

      @route.attributes=route_params
      tmploc=params[:route][:location]

      if tmploc[0..12]=="LINESTRING ZM" then
         tmploc='LINESTRING'+tmploc[13..-1]
         factory=RGeo::Geographic.spherical_factory(:srid => 4326, :has_z_coordinate => true, :has_m_coordinate => true)
         @route.location=factory.parse_wkt(tmploc)
      end
      if tmploc[0..11]=="LINESTRING Z" then
         tmploc='LINESTRING'+tmploc[12..-1]
         factory=RGeo::Geographic.spherical_factory(:srid => 4326, :has_z_coordinate => true)
         @route.location=factory.parse_wkt(tmploc)
      end

      route_add_altitude()
      @route.datasource=params[:datasource]
      @route.updated_at=Time.new()
      @route.updatedBy_id = @current_user.id #current_user.id
      signed_route_id=@route.id
      if @route.save and !@route.customerrors
        if signed_route_id<0 then @route=@route.reverse end #save sets route to 'forwards'
        if @editmany then
          flash[:success]="First segment updated. Now please update the details of the second part of the split route"
        else
          flash[:success] = "Route updated, id:"+@route.id.to_s 
        end
        if @url and @url.include?('x')
            #show routes screen
            #get all data for show many
            @id=@viewurl
            show_many()

            #show the show many screen
            render '/routes/show_many'
        else
          @id=params[:id]=@route.id
          show()
          render 'show'
        end


      else
        if @route.customerrors then
          flash[:error]=@route.customerrors 
        end
        if @url and @url.include?('x') then
            #show routes screen
            #get all data for show many
            @id=@url
            @editroute=@route
            show_many()

            #show the show many screen
            render '/routes/show_many'
        else
          @edit=true
          render 'edit'
        end
      end
     end
    end
  

    if (params[:delete])
     if !signed_in? then
        redirect_to signin_url+"?referring_url="+URI.escape(request.fullpath), notice: "Please sign in." 
     else
 
      if(!trip=TripDetail.find_by(:route_id => params[:id])) 
         
        route=Route.find_by_id(params[:id].to_i.abs)
        if !route then 
          redirect_to '/legs'
        else
          links=route.links
          links.each do |l| 
             l.destroy
          end
          if route.destroy
            flash[:success] = "Route deleted, id:"+params[:id]
            redirect_to '/legs/'
          else
            edit()
            render 'edit'
          end 
        end
      else
        flash[:error] = "Trip "+trip.id.to_s+" uses this route, cannot delete"
        edit()
        render 'edit'
      end
    end
  end
end

def route_add_altitude
  if (@route.location and @route.location.length>0) then
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
         altArr=Dem30.find_by_sql ["
            select ST_Value(rast, ST_GeomFromText(?,4326))  rid
               from dem30s
               where ST_Intersects(rast,ST_GeomFromText(?,4326));",
               'POINT('+p.x.to_s+' '+p.y.to_s+')',
               'POINT('+p.x.to_s+' '+p.y.to_s+')']
  
         linestr+=p.x.to_s+" "+p.y.to_s+" "+altArr.first.try(:rid).to_s
         puts "Alt: "+altArr.first.try(:rid).to_s
      end
      @route.location=linestr+")"
    end
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
       :datasource,
       :importance_id,
       :experienced_at,
       :published)
  end

end
