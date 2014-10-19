class SearchController < ApplicationController


def find
  if !@inname then @inname=true end
  if !@findplaces then @findplaces=true end
  if !@findroutes then @findroutes=true end
  if !@findtrips then @findtrips=true end
  if !@findstories then @findstories=true end
end

def findresults
    @searchtext=params[:searchtext]
    searchtext='%'+params[:searchtext]+'%'
    @findplaces=params[:Places]=="1"
    @findroutes=params[:Routes]=="1"
    @findtrips=params[:Trips]=="1"
    @findstories=params[:Stories]=="1"

    @inname=params[:Name]=="1"
    @indescription=params[:Description]=="1"
    @inextent=params[:Extent]=="1"

    exttext=""
    if @inextent then exttext="and location && ST_MakeEnvelope("+params[:extent_left]+", "+params[:extent_bottom]+", "+params[:extent_right]+", "+params[:extent_top]+")"
      puts exttext
    end

    if @findplaces then
      if @inname then @places=Place.find_by_sql ["select * from places where name ilike ? "+exttext+" order by name",searchtext] end
      if @indescription then @places_text=Place.find_by_sql ["select * from places where description ilike ? "+exttext+" order by name",searchtext] end
    end
    if @findroutes then
      if @inname then @routes=Route.find_by_sql ["select * from routes where name ilike ? "+exttext+" order by name",searchtext] end
      if @indescription then @routes_text=Route.find_by_sql ["select * from routes where (description ilike ? or 'reverse_description' like ?) "+exttext+" order by name",searchtext, searchtext] end
    end
    if @findtrips then
      if @inname then @trips=Trip.find_by_sql ["select * from trips where name ilike ? and published=true order by name",searchtext] end
      if @indescription then @trips_text=Trip.find_by_sql ["select * from trips where description ilike ? and published=true order by name",searchtext] end
    end
    if @findstories then
      if @inname then @stories=Report.find_by_sql ["select * from reports where name ilike ? order by name",searchtext] end
      if @indescription then @stories_text=Report.find_by_sql ["select * from reports where description ilike ? or 'reverse_description' like ? order by name",searchtext, searchtext] end
    end

    render 'find'  
end

  def search
     @trip=true
     prepare_route_vars()
     @searchNow=true

     if(params[:route_startplace_id] and params[:route_endplace_id]) then searchresults() end

  end

  def searchresults
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
       @route_ids=placea.adjoiningPlaces(params[:route_endplace_id].to_i,true,nil,nil,nil)
     else
       @route_ids=nil
     end
     prepare_route_vars()

     render 'search'
  end

end
