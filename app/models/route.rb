class Route < ActiveRecord::Base
 attr_accessor :customerrors
  has_many :routeInstances
 belongs_to :createdBy, class_name: "User"
 belongs_to :updatedBy, class_name: "User"
  validates :createdBy, :presence => true
#  validates :experienced_at, :presence => true

  validates :via, presence: true
  validates :routetype, presence: true
  belongs_to :routetype
  validates :importance, presence: true
  belongs_to :importance, class_name: "RouteImportance"
  validates :gradient, presence: true
  belongs_to :gradient
  validates :terrain, presence: true
  belongs_to :terrain
  validates :alpinesummer, presence: true
  belongs_to :alpinesummer, class_name: "Alpine"
  validates :alpinewinter, presence: true
  belongs_to :alpinewinter, class_name: "Alpinew"
  validates :river, presence: true
  belongs_to :river

  validates :startplace, presence: true
  belongs_to :startplace, class_name: "Place"
  validates :endplace, presence: true
  belongs_to :endplace, class_name: "Place"

  before_validation { |route| route.name = route.startplace.name + " to " + route.endplace.name + " via " + route.via + " ("+route.routetype.name+")" }
  validates :name, uniqueness: true
  after_validation :default_values
  before_save :handle_negatives_before_save

  after_save :create_new_instance
  after_save :queue_regenerate_route_index

  before_destroy :prune_route_index

  set_rgeo_factory_for_column(:location, RGeo::Geographic.spherical_factory(:srid => 4326, :proj4=> '+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs', :has_z_coordinate => true))

def self.find_latest_by_user(count)
  routes=[]
  contributors=Route.find_by_sql [ 'select "createdBy_id" from routes where published=true group by "createdBy_id" order by max(updated_at) desc limit ?', count ]

  contributors.each do |c|
    r=Route.find_by_sql [ 'select * from routes where "createdBy_id" = ? and published=true order by updated_at desc limit 1', c.createdBy_id.to_s] 
    if r and r.count>0 then routes=routes+r end
  end
  routes
end

def self.find_by_signed_id(id)
   id=id.to_i
   route=Route.find_by_id(id.abs)

   if id<0 and route then
     route=route.reverse
   end

   route
end

def distance_from_place(place)
  (Route.find_by_sql [ "SELECT ST_Distance( (select geography(location) from places where id=?), (select geography(location) from routes where id=?)) as distance;", place.id, self.id]).first.try('distance')

end

def esttime
   est=0
   var=0
  #if self.time then 
 #    est=self.time
#     var=0
#  else
    #try average
    ev=Route.find_by_sql [ "select stddev_pop(time/distance) as var, avg(time/distance) as time from routes where routetype_id=? and terrain_id=? and gradient_id=? and time>0 and distance>0 and published=true;", self.routetype_id, self.terrain_id, self.gradient_id ]
   if ev and ev.count==1 then
     est=ev[0].time*self.distance
     var=ev[0].var*self.distance
   else
     #try slope
     ev=(Route.find_by_sql [ "select stddev_pop(time/distance) as distance, avg(time/distance) as time from routes where routetype_id=? and time>0 and distance>0 and published=true", self.routetype_id ] ).first
     gs=(Route.find_by_sql [ "select avg((altgain+altloss)/distance) as altgain, regr_r2(time/distance, (altgain+altloss)/distance) as distance, regr_slope(time/distance, (altgain+altloss)/distance) as time from routes where time>0 and routetype_id=?;",self.routetype_id]).first
     if ev and gs then
     tpkm=ev[:time]+(((self.altgain+self.altloss)/self.distance)-gs.altgain)*gs.distance
     est=tpkm*self.distance
     var=(ev.distance+gs.time*(1-gs.distance))*self.distance
    end
#   end
  end
  {time: est, var: var}
end

def esttime2
   est=0
   var=0
     #try slope
     ev=(Route.find_by_sql [ "select stddev_pop(time/distance) as distance, avg(time/distance) as time from routes where routetype_id=? and time>0 and distance>0 and published=true", self.routetype_id ] ).first
     gs=(Route.find_by_sql [ "select avg((altgain+altloss)/distance) as altgain, regr_r2(time/distance, (altgain+altloss)/distance) as distance, regr_slope(time/distance, (altgain+altloss)/distance) as time from routes where time>0 and distance>0 and routetype_id=?;",self.routetype_id]).first
     if ev and gs then
     tpkm=ev[:time]+(((self.altgain+self.altloss)/self.distance)-gs.altgain)*gs.time
     est=tpkm*self.distance
     var=(ev.distance+gs.time*(1-gs.distance))*self.distance
  end
  {time: est, var: var}
end

def split(splitplace)
   r2=nil
  # check that splitplace in within tolerance of route
  if(distance=self.distance_from_place(splitplace)) > 200 then
    self.customerrors="Cannot split. Place is >200m from route ("+distance.to_s+"m)"
  end
  if !self.customerrors then
    # create duplicate route
    r2=self.dup

    # split the route
    route_segments=Route.find_by_sql [ "select (ST_Dump(ST_Split(ST_Snap(b.location, a.location, 0.003), a.location))).geom as location from places a join routes b on b.id=? where a.id=?", self.id, splitplace.id ]
    if route_segments.count<2 then self.customerrors="Fewer than 2 segments resulted from split" end
  end
  if !self.customerrors then
    startroute=route_segments[0].location
    endroute=route_segments[1].location
    if !(startroute and endroute and startroute.length>0 and endroute.length>0) then
      self.customerrors="One of resulting segments had zero length"
    end
  end

  if !self.customerrors then
    # insert segments into routes
    self.location=location_without_nan(startroute)
    r2.location=location_without_nan(endroute)

    # change startplace of new route
    r2.startplace=splitplace
    r2.via=r2.via+" part 2"
    r2.distance=r2.location.length/1000
    r2.calc_altgain
    r2.calc_altloss
    r2.calc_minalt
    r2.calc_maxalt

    if !r2.save  then self.customerrors="Failed to save new route - "+r2.errors.messages.to_s end

  end

  if !self.customerrors then
    # change endplace of old route
    self.endplace=splitplace
    self.via=self.via+" part 1"
    self.distance=self.location.length/1000
    self.calc_altgain
    self.calc_altloss
    self.calc_minalt
    self.calc_maxalt

    if !self.save then 
      self.customerrors="Failed to update old route - "+self.errors.messages.to_s 
      r2.destroy
    end
  end
  
  if !self.customerrors then
  
    # copy links
    self.links.each do |lnk|
      l=Link.find_by_id(lnk)
      l2=l.dup
      if l2.baseItem_id==self.id then l2.baseItem_id=r2.id else l2.item_id=r2.id end
      if !l2.save  then 
           self.customerrors="Route has been split, but failed creating a link for the new route: "+l2.errors.messages.to_s
      end
    end
  end

  if !self.customerrors then     
    # insert newroute after oldroute in trips (or -newroute before -oldroute)
    trip_ids=(TripDetail.find_by_sql ["select trip_id from trip_details where route_id = ? or route_id=?", self.id, -self.id]).uniq
    trip_ids.each do |tid|
      t=Trip.find_by_id(tid.trip_id)
        
      #find this route within this trip and add new route before / after
      after=[]
      before=[]
      order=1
      t.trip_details.order(:order).each do |td|
        if td.route_id==self.id then
          #insert after this td
          td.order=order
          td.save
          order+=1
          if !td2=TripDetail.create(:order => order, :route_id => r2.id, :trip_id => t.id) then 
            self.customerrors="Route has been split, but failed to update a trip to use the new split route: "+td2.errors.messages.to_s end
          order+=1
        else 
          #insert before this td
          if td.route_id==-self.id then
            if !td2=TripDetail.create(:order => order, :route_id => -r2.id, :trip_id => t.id) then
              self.customerrors="Route has been split, but failed to update a trip to use the new split route:  "+td2.errors.messages.to_s end
            order+=1
            td.order=order
            td.save
            order+=1
          else
            #just copy original td
            td.order=order
            if !td.save then self.customerrors="Route has been split, but failed to update a trip to use the new split route:  "+td.errors.messages.to_s end
            order+=1
          end
        end
      end
    end
  end
 #puts self.customerrors
 r2
end

def reverse


   temp=self.startplace_id
   self.startplace_id=self.endplace_id
   self.endplace_id = temp
   self.id=-self.id
   if self.location then
     linestr="LINESTRING("
     self.location.points.reverse.each do |p|
       if linestr.length>11 then linestr+="," end
       linestr+=p.x.to_s+" "+p.y.to_s+" "+p.z.to_s
     end
     self.location=linestr+")"
   end


   tempstr=self.description
   self.description=self.reverse_description
   self.reverse_description=tempstr

   self.name=self.startplace.name+" to "+self.endplace.name+" via "+self.via
   ag=self.altgain
   self.altgain=self.altloss
   self.altloss=ag

   self
   
end

def default_values
    if !self.datasource or self.datasource.length<1 then
        self.datasource = 'drawn on map'
    end
    self.created_at ||= self.updated_at
    calc_altgain
    calc_altloss
    calc_minalt
    calc_maxalt

    starterr=self.errors.count

    if self.published==true
      str=""
     # str+="location (route points) is blank, " if !self.location
     self.errors.messages[:location]=["can't be blank for a published route"] if !self.location
     # str+="time is blank or 0, " if !self.time or self.time==0
     self.errors.messages[:time]=["can't be blank for a published route"] if !self.time or self.time==0

     # str+="date experienced is blank, " if !self.experienced_at 
     self.errors.messages[:experienced_at]=["can't be blank for a published route"] if !self.experienced_at

     # str+="descriptions are both blank, " if (!self.description or self.description.strip=="") and (!self.reverse_description or self.reverse_description.strip=="")
     self.errors.messages[:description]=["or Reverse description is required for a published route"] if (!self.description or self.description.strip=="") and (!self.reverse_description or self.reverse_description.strip=="")

      if self.errors.count>starterr then 
        self.customerrors="Enter the required information and save again, or uncheck 'published' if you wish to save this as a draft version without this information"
        false
      else
        true
      end
    end
  end

def handle_negatives_before_save
    if self.id and self.id<0 then
      self.reverse
    else
      self
    end
end

def create_new_instance
   if self.id<0 then
       route=self.reverse
   else route=self
   end

   route_instance=RouteInstance.new(route.attributes.except('created_at', 'updated_at'))
   route_instance.route_id=route.id
   route_instance.id=nil
   route_instance.createdBy_id = route.updatedBy_id #current_user.id

   route_instance.save
end


def firstexperienced_at
     t=Route.find_by_sql ["select created_at, experienced_at from route_instances  
                where route_id = ? order by created_at limit 1", self.id.abs]
     t.first.try(:experienced_at) || "1900-01-01".to_datetime

end

def firstcreated_at
     t=Route.find_by_sql ["select min(rd.created_at) id from route_instances rd 
                where rd.route_id = ?", self.id.abs]
     t.first.try(:id)  || "1900-01-01".to_datetime
end

def revision_number
     t=Route.find_by_sql ["select count(id) id from route_instances ri 
                 where ri.route_id = ? and ri.updated_at <= ?",self.id.abs, self.updated_at]
     t.first.try(:id)
end

def adjoiningRoutes
#   t=Route.find_by_sql ["select distinct *  from routes r 
#       where published=true and (startplace_id = ? or endplace_id = ? or startplace_id = ? or endplace_id = ?) and id <> ?",self.startplace_id, self.startplace_id, self.endplace_id, self.endplace_id, self.id.abs]
   t=self.startplace.adjoiningRoutes
   t+=self.endplace.adjoiningRoutes
   self.linked('place').each do |lp|
     pl=Place.find_by_id(lp.item_id)
     t+=pl.adjoiningRoutes
   end
 
   adjr=[] 
   rsofar=[]
   t.each do |lr|
      drop=false
      if lr.id.abs==self.id.abs then  drop=true  end
      if rsofar.include? lr.id then drop=true end
      if drop==false then adjr+=[lr] end
      rsofar+=[lr.id]
   end
   adjr
      
end

def adjoiningPlaces
   aps=self.startplace.adjoiningPlaceListFast+self.endplace.adjoiningPlaceListFast
end
def parents
   t=RouteIndex.find_by_sql [%q[select distinct * from route_indices ri where ri.url like '%xr?x%' or ri.url like '%xr?'], self.id.abs, self.id.abs]
   r=t.sort_by{|a| [a.startplace.name, a.endplace.name]}
end

def trips
   t=Route.find_by_sql ["select distinct t.* from trips t
       inner join trip_details td on td.trip_id = t.id
       where (td.route_id = ? or td.route_id = ?) and t.published=true",self.id, -self.id]
end
def links
   r=Link.find_by_sql [%q[select distinct id, item_id, item_type, item_url from links l
              where (l."baseItem_type"='route' and l."baseItem_id"=?) 
        union select distinct id, "baseItem_id" as item_id, "baseItem_type" as item_type, '' as item_url from links l
              where  (l.item_type='route' and l.item_id=?)],self.id.abs, self.id.abs]
end

def linked(type)
   r=Link.find_by_sql [%q[select distinct id, item_id, item_type, item_url from links l
              where (l."baseItem_type"='route' and l."baseItem_id"=? and item_type=?) 
        union select distinct id, "baseItem_id" as item_id, "baseItem_type" as item_type, '' as item_url from links l
              where  (l.item_type='route' and l.item_id=? and "baseItem_type"=?)],self.id.abs, type, self.id.abs, type]
end


def calc_maxalt
   alt=0
   if(self.location) then
     self.location.points.each do |p|
       if(p.z)>alt then alt=p.z end
     end
   end
   self.maxalt=alt 
end

def calc_minalt
   alt=9999
   if(self.location) then
     self.location.points.each do |p|
       if(p.z)<alt then alt=p.z end
     end
    self.minalt=alt
   else self.minalt=0
   end
end

def calc_altgain
   alt=0
   if(self.location) then
     lastalt=self.location.points.first.z
     self.location.points.each do |p|
         if(p.z)>lastalt then alt+=p.z-lastalt end
         lastalt=p.z
     end
   end
   self.altgain=alt

end

def calc_altloss
   alt=0
   if(self.location) then
     lastalt=self.location.points.first.z
     self.location.points.each do |p|
       if(p.z)<lastalt then alt+=lastalt-p.z end
       lastalt=p.z
     end
   end
   self.altloss=alt

end

def queue_regenerate_route_index
        if Rails.env.production? then Resque.enqueue(Indexer,self.id) end
end

def regenerate_route_index
  starttime=Time.now()
  maxLegCount=14 #15
  newcount=0

  #delete old entries using this route
  puts "Deleting old entries" if ENV["RAILS_ENV"] != "test"

  RouteIndex.where("url ~ ? or url ~ ?",'x[rq]v[-]{0,1}'+self.id.to_s+'x', 'x[rq]v[-]{0,1}'+self.id.to_s+'$').destroy_all

  if self.published==true then
    puts "Finding routes from start: "+(Time.now()-starttime).to_s+" seconds" if ENV["RAILS_ENV"] != "test"
    #find all place-to-place routes of length < <maxhops-1> for the start or endplace
    startAffectedRoutes=[{:place => self.startplace.id, :placelist => [self.startplace.id], :route => [], :url => ''}]+self.startplace.adjoiningPlaces(nil,false,maxLegCount-1, nil,self.id)
    
    rsar=[]
    startAffectedRoutes.each do |ar|
      #routes traversing us start->end
      rar=reverseRouteHash(ar)
      rsar=rsar+[rar]
    end


    puts "Finding routes from end: "+(Time.now()-starttime).to_s+" seconds" if ENV["RAILS_ENV"] != "test"
    endAffectedRoutes=[{:place => self.endplace.id, :placelist => [self.endplace.id], :route => [], :url => ''}]+self.endplace.adjoiningPlaces(nil,false,maxLegCount-1, nil,-self.id)

    rear=[]
    endAffectedRoutes.each do |ar|
      #routes traversing us end->start 
      rar=reverseRouteHash(ar)
      rear=rear+[rar]
    end
  
    #and any linked places
    puts "Finding routes from links: "+(Time.now()-starttime).to_s+" seconds" if ENV["RAILS_ENV"] != "test"
    linkedAffectedRoutes=[]
    rlar=[]
    link=0
    self.linked('place').each do |lp|
      linkplace=Place.find_by_id(lp.item_id)
      linkedAffectedRoutes[link]=[{:place => linkplace.id, :placelist => [linkplace.id], :route => [], :url => ''}]+linkplace.adjoiningPlaces(nil,false,maxLegCount-1, nil,self.id)

      rlar[link]=[]
      #routes traversing us link->end
      linkedAffectedRoutes[link].each do |ar|
        rar=reverseRouteHash(ar)
        rlar[link]=rlar[link]+[rar]
      end
      link+=1
    end
    
    puts "Generating start<->end: "+(Time.now()-starttime).to_s+" seconds" if ENV["RAILS_ENV"] != "test"
    #recalculate all routes from the route's startplace that go via us
    #start <-> end
    ourUrl="xrv"+self.id.to_s 
    rsar.each do |sar|
      endAffectedRoutes.each do |ear|
        fullroute= sar[:url]+ourUrl+ear[:url] 
        if fullroute and fullroute.split('x').count<maxLegCount+1 then
          if ((sar[:route].map!(&:abs) & ear[:route].map!(&:abs)).count ==0)  and ((sar[:placelist] & ear[:placelist]).count == 0) # count of matching abs(route.id) in both URLs=0
            createRI(sar[:startplace],fullroute,ear[:place])
            newcount+=2
          end
 
        end
      end
    end 

    puts "Generating start<->links: "+(Time.now()-starttime).to_s+" seconds" if ENV["RAILS_ENV"] != "test"
    #start <-> links   
    link=0
    self.linked('place').each do |lp|
      ourUrl="xqv"+self.id.to_s+"y"+self.startplace_id.to_s+"y"+lp.item_id.to_s
      rsar.each do |sar|
        linkedAffectedRoutes[link].each do |lr|
          fullroute= sar[:url]+ourUrl+lr[:url]
          if fullroute and fullroute.split('x').count<maxLegCount+1 then
            if ((sar[:route].map!(&:abs) & lr[:route].map!(&:abs)).count ==0) and ((sar[:placelist] & lr[:placelist]).count == 0)
              #this should to be adapted to check _linked_places too
              #placesWithLinks(sar[:placelist]) & placesWithLinks(lr[:placelist])
              #but at what cost in time ...?
              createRI(sar[:startplace],fullroute,lr[:place])
              newcount+=2
            end
  
          end
        end
      end
    link+=1
    end

    puts "Generating end<->links: "+(Time.now()-starttime).to_s+" seconds" if ENV["RAILS_ENV"] != "test"
    #end <-> links
    link=0
    self.linked('place').each do |lp|
      ourUrl="xqv"+(-self.id).to_s+"y"+self.endplace_id.to_s+"y"+lp.item_id.to_s
      rear.each do |ear|
        linkedAffectedRoutes[link].each do |lr|
          fullroute= ear[:url]+ourUrl+lr[:url]
          if fullroute and fullroute.split('x').count<maxLegCount+1 then
            if ((ear[:route].map!(&:abs) & lr[:route].map!(&:abs)).count ==0) and ((ear[:placelist] & lr[:placelist]).count == 0)
              createRI(ear[:startplace],fullroute,lr[:place])
              newcount+=2
            end
  
          end
        end
      end
    link+=1
    end

    puts "Generating links<->links: "+(Time.now()-starttime).to_s+" seconds" if ENV["RAILS_ENV"] != "test"
    #links <-> links
    linka=0
    self.linked('place').each do |lpa|
      linkb=0
      self.linked('place').each do |lpb|
        #only do this when a>b or we will get everything twice
        if lpa.item_id>lpb.item_id then
          rlar[linka].each do |lra|
            linkedAffectedRoutes[linkb].each do |lrb|
              ourUrl="xqv"+self.id.to_s+"y"+lpa.item_id.to_s+"y"+lpb.item_id.to_s
              fullroute= lra[:url]+ourUrl+lrb[:url]
              if fullroute and fullroute.split('x').count<maxLegCount+1 then
                if ((lra[:route].map!(&:abs) & lrb[:route].map!(&:abs)).count ==0) and ((lra[:placelist] & lrb[:placelist]).count == 0)
                  createRI(lra[:startplace],fullroute,lrb[:place])
                  newcount+=2
                end
              end
            end
          end
        end
        linkb+=1
      end
      linka+=1
    end
   
  end
  puts "Completed: "+newcount.to_s+" routes added/updated in "+(Time.now()-starttime).to_s+" seconds" if ENV["RAILS_ENV"] != "test"
end

def createRI(startplace, baseRoute, endplace)
   place=Place.find_by_id(startplace)
   endPlace=Place.find_by_id(endplace)
   isStub=(endPlace.adjoiningRoutes.count<2)
   urlindex=0
   routeStr=baseRoute.split('x')[1..-1]
   routelist=""
   rrgz=""
   rrlz=""
   gzrl=""
   lzrl=""
   direct=0
   routeStr.each do |r| 
     nr=r[2..-1].to_i
     routelist+=", "+nr.abs.to_s
     rrgz+=", "+nr.abs.to_s if (r[0]=="r" and nr>0)
     rrlz+=", "+nr.abs.to_s if (r[0]=="r" and nr<0)
     gzrl=gzrl+", "+nr.to_s if nr>0
     lzrl=lzrl+", "+nr.abs.to_s if nr<0
     if  r[0]=='q' then
        rtarr=r[2..-1].split('y')
        nextPlace=Place.find_by_id(rtarr[2].to_i)
        direct+=1 if nextPlace.isLocatedAtHut
     end
   end
   query="select sum(distance) as distance, sum(time) as time, max(maxalt) as maxAlt, min(minalt) as minAlt, max(importance_id) as maxImportance, max(routetype_id) as maxRouteType, max(gradient_id) as maxGradient, max(terrain_id) as maxTerrain, max(alpinesummer_id) as maxAlpineS,  max(alpinewinter_id) as maxAlpineW, max(river_id) as maxRiver,   sum(routetype_id*distance)/nullif(sum(distance),0) as avgRouteType, sum(importance_id*distance)/nullif(sum(distance),0) as avgImportance, sum(gradient_id*distance)/nullif(sum(distance),0) as avgGradient, sum(alpinesummer_id*distance)/nullif(sum(distance),0) as avgAlpineS, sum(alpinewinter_id*distance)/nullif(sum(distance),0) as avgAlpineW, sum(river_id*distance)/nullif(sum(distance),0) as avgRiver from routes where id in ("+routelist[1..-1]+")"
   ri=RouteIndex.new((RouteIndex.find_by_sql [ query ]).first.attributes)

  if rrlz!="" then 
    places=(Route.find_by_sql [ "select startplace_id as id  from routes where id in ("+rrlz[1..-1]+")" ]).map { |f| f.id }.join ","

    #main places
    query="select count(p.id) as id from places p where p.id in ("+places+") and p.place_type='Hut'"
    direct+=(RouteIndex.find_by_sql [ query ]).first.id
    #now linked places
    query=%q{select count(l.id) as id from links l inner join places p on p.id=l.item_id where l.item_type='place' and l."baseItem_type"='place' and p.place_type='Hut' and l."baseItem_id" in (}+places+")"
    direct+=(Link.find_by_sql [ query ]).first.id
    query=%q{select count(l.id) as id from links l inner join places p on p.id=l."baseItem_id" where l.item_type='place' and l."baseItem_type"='place' and p.place_type='Hut' and l.item_id in (}+places+")"
    direct+=(Link.find_by_sql [ query ]).first.id
  end
  if rrgz!="" then 
    places=(Route.find_by_sql [ "select endplace_id as id  from routes where id in ("+rrgz[1..-1]+")" ]).map { |f| f.id }.join ","
    #main places
    query="select count(p.id) as id from places p where p.id in ("+places+") and p.place_type='Hut'"
    direct+=(RouteIndex.find_by_sql [ query ]).first.id
    #now linked places
    query=%q{select count(l.id) as id from links l inner join places p on p.id=l.item_id where l.item_type='place' and l."baseItem_type"='place' and p.place_type='Hut' and l."baseItem_id" in (}+places+")"
    direct+=(Link.find_by_sql [ query ]).first.id
    query=%q{select count(l.id) as id from links l inner join places p on p.id=l."baseItem_id" where l.item_type='place' and l."baseItem_type"='place' and p.place_type='Hut' and l.item_id in (}+places+")"
    direct+=(Link.find_by_sql [ query ]).first.id
  end
  rigz=nil
  if gzrl!="" then
    query= "select sum(altgain) as altgain, sum(altloss) as altloss from routes where id in ("+gzrl[1..-1]+")"
    rigz=(RouteIndex.find_by_sql [ query ] ).first
  end
  
  rilz=nil 
  if lzrl!="" then
    query="select sum(altgain) as altgain, sum(altloss) as altloss from routes where id in ("+lzrl[1..-1]+")"
    rilz=(RouteIndex.find_by_sql [ query  ]).first
  end
  ri.altgain=(rigz.try(:altgain) or 0)+(rilz.try(:altloss) or 0)
  ri.altloss=(rigz.try(:altloss) or 0)+(rilz.try(:altgain) or 0)
 
  ri.startplace_id = place.id
  ri.endplace_id = endPlace.id
  ri.isdest = (endPlace.isLocatedAtDest or isStub)
  ri.fromdest = place.isLocatedAtDest
  ri.url = baseRoute
  if endPlace.isLocatedAtHut then direct=direct-1 end
  ri.direct=(direct==0)


   existing=RouteIndex.find_by_sql [ "select * from route_indices where url = ? and startplace_id = ? and endplace_id = ?",baseRoute, place.id.to_s, endPlace.id.to_s ]
   if existing.count==0 and place.id!=endPlace.id then
      ri.save

      #reverse it
      ri2=ri.dup
      ri2.startplace_id=endPlace.id
      ri2.endplace_id=place.id
      ri2.url=reverseRouteUrl(baseRoute)
      ri2.altgain=ri.altloss
      ri2.altloss=ri.altgain
      ri2.fromdest=ri.isdest
      ri2.isdest=ri.fromdest



      ri2.save

      #mark start and end places as changed
      ActiveRecord::Base.record_timestamps = false
      place.save
      endPlace.save
      ActiveRecord::Base.record_timestamps = true

  end
end


def createRIold(startplace, baseRoute, endplace)
   place=Place.find_by_id(startplace)
   endPlace=Place.find_by_id(endplace)
   isStub=(endPlace.adjoiningRoutes.count<2)
   ri=RouteIndex.new(
              :startplace_id => place.id,
              :endplace_id => endPlace.id,
              :isdest => (endPlace.isDest or isStub),
              :fromdest => place.isDest,
              :url => "",
              :time => 0,
              :direct => true,
              :distance => true,
              :altgain => 0,
              :altloss => 0,
              :minalt => 9999,
              :maxalt => 0,
              :maxroutetype => 0,
              :maximportance => 0,
              :maxgradient => 0,
              :maxterrain => 0,
              :maxalpines => 0,
              :maxalpinew => 0,
              :maxriver => 0,
              :avgroutetype => 0,
              :avgimportance => 0,
              :avggradient => 0,
              :avgterrain => 0,
              :avgalpines => 0,
              :avgalpinew => 0,
              :avgriver => 0
            )

  lastIsDirect=true
  routeSoFar=[]
  placeSoFar=[startplace]

  urlSoFar=baseRoute
  urlindex=0
  routeStr=baseRoute.split('x')[1..-1]
  routeStr.each do |rs|
     if rs[0]=='r' or rs[0]=='q' then
         #next place is route endplace unless we have links (aaarghh.  horrible hack)
         if  rs[0]=='r' then
           thisRoute=rs[2..-1].to_i
           currentLeg=Route.find_by_signed_id(thisRoute)
           placeSoFar=[currentLeg.endplace_id]+placeSoFar
           currentDirect=(currentLeg.endplace.isLocatedAtHut)
         else
           rtarr=rs[2..-1].split('y')
           if rtarr.count<3 then abort() end
           thisRoute=rtarr[0].to_i
           currentLeg=Route.find_by_signed_id(thisRoute)
           placeSoFar[0]=rtarr[2].to_i+placeSoFar[0]
           nextPlace=Place.find_by_id(rtarr[2].to_i)
           currentDirect=(nextPlace.isLocatedAtHut)
         end
         routeSoFar=[thisRoute]+routeSoFar
         urlindex+=1
         ri.distance+=(currentLeg.distance or 0)
         ri.time+=(currentLeg.time or 0)
         lastIsDirect=ri.direct
         ri.direct= !(!ri.direct or currentDirect)
         ri.altgain+=currentLeg.altgain
         ri.altloss+=currentLeg.altloss
         ri.maxalt=[ri.maxalt,(currentLeg.maxalt.to_i or 0)].max
         ri.minalt=[ri.minalt,(currentLeg.minalt.to_i or 9999)].min
         ri.maximportance=[ri.maximportance,currentLeg.importance_id].max
         ri.maxroutetype=[ri.maxroutetype,currentLeg.routetype_id].max
         ri.maxgradient=[ri.maxgradient,currentLeg.gradient_id].max
         ri.maxterrain=[ri.maxterrain,currentLeg.terrain_id].max
         ri.maxalpines=[ri.maxalpines,currentLeg.alpinesummer_id].max
         ri.maxalpinew=[ri.maxalpinew,currentLeg.alpinewinter_id].max
         ri.maxriver=[ri.maxriver,currentLeg.river_id].max
         ri.avgimportance+=currentLeg.importance_id*currentLeg.distance
         ri.avgroutetype+=currentLeg.routetype_id*currentLeg.distance
         ri.avggradient+=currentLeg.gradient_id*currentLeg.distance
         ri.avgterrain+=currentLeg.terrain_id*currentLeg.distance
         ri.avgalpines+=currentLeg.alpinesummer_id*currentLeg.distance
         ri.avgalpinew+=currentLeg.alpinewinter_id*currentLeg.distance
         ri.avgriver+=currentLeg.river_id*currentLeg.distance
      end
   end

   existing=RouteIndex.find_by_sql [ "select * from route_indices where url = ? and startplace_id = ? and endplace_id = ?",urlSoFar, place.id.to_s, endPlace.id.to_s ]
   if existing.count==0 and place.id!=endPlace.id then
            ri.url=urlSoFar
            ri.direct = lastIsDirect
            ri.avgimportance = ri.avgimportance/ri.distance
            ri.avgroutetype = ri.avgroutetype/ri.distance
            ri.avggradient = ri.avggradient/ri.distance
            ri.avgterrain = ri.avgterrain/ri.distance
            ri.avgalpines = ri.avgalpines/ri.distance
            ri.avgalpinew = ri.avgalpinew/ri.distance
            ri.avgriver = ri.avgriver/ri.distance
            ri.save

            #reverse it
            ri2=ri.dup
            ri2.startplace_id=endPlace.id
            ri2.endplace_id=place.id
            ri2.url=reverseRouteUrl(urlSoFar)
            ri2.altgain=ri.altloss
            ri2.altloss=ri.altgain
            ri2.save

            #mark start and end places as changed
            ActiveRecord::Base.record_timestamps = false
            place.save
            endPlace.save
            ActiveRecord::Base.record_timestamps = true

  end
end


def regenerate_route_index_old
  starttime=Time.now()
  maxLegCount=15 #15

  #delete old entries using this route
  puts "Deleting old entries" if ENV["RAILS_ENV"] != "test"
  RouteIndex.where("url ~ ? or url ~ ?",'x[rq]v[-]{0,1}'+self.id.to_s+'x', 'x[rq]v[-]{0,1}'+self.id.to_s+'$').destroy_all
  puts "Finding affected places" if ENV["RAILS_ENV"] != "test"

  if self.published==true then
    #find all place-to-place routes of length < <maxhops-1> for the start or endplace
    startAffectedRoutes=[{:place => self.startplace.id, :route => [], :url => ''}]+self.startplace.adjoiningPlaces(nil,false,maxLegCount-1, nil,self.id)
    #if self.startplace.placeType.isDest then startAffectedRoutes=[{:place => self.startplace_id, :route => [], :url => ''}]
    #else startAffectedRoutes=[] end
    #startAffectedRoutes+=self.startplace.adjoiningPlaces(nil,false,maxLegCount-1, nil,self.id)
    endAffectedRoutes=[{:place => self.endplace.id, :route => [], :url => ''}]+self.endplace.adjoiningPlaces(nil,false,maxLegCount-1, nil,-self.id)
    #if self.endplace.placeType.isDest then endAffectedRoutes=[{:place => self.endplace_id, :route => [], :url => ''}]
    #else endAffectedRoutes=[] end
    #endAffectedRoutes+=self.endplace.adjoiningPlaces(nil,false,maxLegCount-1, nil,self.id)
  
    #reverse the above routes (so get them TO us, no FROM us) 
    #and add the leg we are saving to the end of the route
    rsar=[]
    startAffectedRoutes.each do |ar|
      #routes traversing us start->end
      rar=reverseRouteHash(ar)
      rar[:url]=rar[:url]+"xrv"+self.id.to_s
      rar[:route]=[self.id]+rar[:route]
      rar[:place]=self.endplace.id
      rar[:startplace]=ar[:place]
      rsar=rsar+[rar]
      #routes traversing us start->link
      self.linked('place').each do |lp|
        rar=reverseRouteHash(ar)
        rar[:url]=rar[:url]+"xqv"+self.id.to_s
        rar[:route]=[self.id]+rar[:route]
        rar[:place]=lp.item_id
        rar[:startplace]=ar[:place]
        rsar=rsar+[rar]
      end
    end

    rear=[]
    endAffectedRoutes.each do |ar|
      #routes traversing us end->start 
      rar=reverseRouteHash(ar)
      rar[:url]=rar[:url]+"xrv"+(-self.id).to_s
      rar[:route]=[-self.id]+rar[:route]
      rar[:place]=self.startplace.id
      rar[:startplace]=ar[:place]
      rear=rear+[rar]
      #routes traversing us end->link
      self.linked('place').each do |lp|
        rar=reverseRouteHash(ar)
        rar[:url]=rar[:url]+"xqv"+(-self.id).to_s
        rar[:route]=[-self.id]+rar[:route]
        rar[:place]=lp.item_id
        rar[:startplace]=ar[:place]
        rear=rear+[rar]

      end
    end
  
    allAR=rsar+rear


    #and any linked places
    self.linked('place').each do |lp|
      linkplace=Place.find_by_id(lp.item_id)
      startAffectedRoutes=[{:place => linkplace.id, :route => [], :url => ''}]+linkplace.adjoiningPlaces(nil,false,maxLegCount-1, nil,self.id)
      endAffectedRoutes=[{:place => linkplace.id, :route => [], :url => ''}]+linkplace.adjoiningPlaces(nil,false,maxLegCount-1, nil,-self.id)

      rsar=[]
      #routes traversing us link->end
      startAffectedRoutes.each do |ar|
        rar=reverseRouteHash(ar)
        rar[:url]=rar[:url]+"xqv"+self.id.to_s
        rar[:route]=[self.id]+rar[:route]
        rar[:place]=self.endplace.id
        rar[:startplace]=ar[:place]
        rsar=rsar+[rar]
      end
    
      rear=[]
      #routes traversing us link->start
      endAffectedRoutes.each do |ar|
    
        rar=reverseRouteHash(ar)
        rar[:url]=rar[:url]+"xqv"+(-self.id).to_s
        rar[:route]=[-self.id]+rar[:route]
        rar[:place]=self.startplace.id
        rar[:startplace]=ar[:place]
        rear=rear+[rar]
      end
    
      allAR=allAR+rsar+rear
    end

    #recalculate all routes from the route's startplace that go via us

    puts "Regenerating "+allAR.count.to_s+" routes from affected places via us" if ENV["RAILS_ENV"] != "test"
    #recalculate all routes from the route's startplace that go via us
    newcount=0
    allAR.each do |ar|
      #get start place
      place=Place.find_by_id(ar[:startplace])
      #regernarate routes from place using this route as base-route   
      newRoutes=place.adjoiningPlaces(nil,false,maxLegCount,ar,nil)
       newRoutes.each do |newRoute|
        
          endPlace_id=newRoute[:place]
          endPlace=Place.find_by_id(endPlace_id)
 
          existing=RouteIndex.find_by_sql [ "select * from route_indices where url = ? and startplace_id = ? and endplace_id = ?",newRoute[:url], place.id.to_s, endPlace.id.to_s ]
          if existing.count==0 and place.id!=endPlace.id then
            newcount+=1
            ri=RouteIndex.new(:startplace_id => place.id, 
                              :endplace_id => endPlace.id, 
                              :isdest => (endPlace.isDest or newRoute[:isStub]), 
                              :fromdest => place.isDest,
                              :url => newRoute[:url], 
                              :direct => newRoute[:direct], 
                              :time => newRoute[:time], 
                              :distance => newRoute[:distance],
                              :altgain => newRoute[:altgain],
                              :altloss => newRoute[:altloss],
                              :maxalt => newRoute[:maxalt],
                              :minalt => newRoute[:minalt],
                              :maximportance => newRoute[:maximportance],
                              :maxroutetype => newRoute[:maxroutetype],
                              :maxgradient => newRoute[:maxgradient],
                              :maxterrain => newRoute[:maxgradient],
                              :maxalpines =>newRoute[:maxalpines],
                              :maxalpinew =>newRoute[:maxalpinew],
                              :maxriver => newRoute[:maxriver],
                              :avgimportance =>newRoute[:avgimportance],
                              :avgroutetype =>newRoute[:avgroutetype],
                              :avggradient =>newRoute[:avggradient],
                              :avgterrain =>newRoute[:avgterrain],
                              :avgalpines =>newRoute[:avgalpines],
                              :avgalpinew =>newRoute[:avgalpinew],
                              :avgriver => newRoute[:avgriver]
                              )
            ri.save
            #mark start and end places as changed
            ActiveRecord::Base.record_timestamps = false
            place.save
            endPlace.save
            ActiveRecord::Base.record_timestamps = true

          end
       end
    end  
  end
  puts "Completed: "+newcount.to_s+" routes added/updated in "+(Time.now()-starttime).to_s+" seconds" if ENV["RAILS_ENV"] != "test"
end

def reverseRouteUrl(urlstr)
   url=""
   oldurl=urlstr.split('x')[1..-1]
   urlindex=0
   oldurl.each do |rt|
     if rt[0]=="q"
       arr=rt[2..-1].split('y')
       url="xqv"+(-(arr[0].to_i)).to_s+"y"+arr[2]+"y"+arr[1]+url
     else
       url="xrv"+(-(rt[2..-1].to_i)).to_s+url
     end
     urlindex+=1
   end
   url
end

def reverseRouteHash(routeHash)
   route=[]
   placelist=[]
   url=""
   if routeHash[:route].count>0 then 
     oldurl=routeHash[:url].split('x')[1..-1]
     urlindex=oldurl.count-1
     routeHash[:route].each do |rt|
       route=[-rt]+route
       if oldurl[urlindex][0]=="q"
         arr=oldurl[urlindex][2..-1].split('y')
         url=url+"xqv"+(-(arr[0].to_i)).to_s+"y"+arr[2]+"y"+arr[1]
       else
         url=url+"xrv"+(-rt).to_s
       end
       urlindex-=1
     end
     routeHash[:placelist].each do |pl|
       placelist=[pl]+placelist
     end
     #get endplace (remembering that we need to reverse the last leg direction first)
     rt=routeHash[:route].last
     place=Route.find_by_signed_id(rt).try(:startplace_id)
   else
     place=routeHash[:place]
   end
   {:place => place, :placelist => placelist, :route => route, :url => url, :startplace => routeHash[:place]}
end

def prune_route_index
  #delete old entries using this route
  RouteIndex.where("url ~ ? or url ~ ?",'x[rq]v[-]{0,1}'+self.id.abs.to_s+'x', 'x[rq]v[-]{0,1}'+self.id.abs.to_s+'$').destroy_all
end

def location_without_nan(locn)
   if locn then
     lastz=nil
     linestr="LINESTRING("
     locn.points.each do |p|
       if linestr.length>11 then linestr+="," end
       z=p.z
       if z.nan? then
         if lastz then 
           z=lastz 
         else
           if locn.points.count>1 then z=locn.points[1].z else z=0 end
         end
       end
       linestr+=p.x.to_s+" "+p.y.to_s+" "+z.to_s
       lastz=p.z
     end
     locn=linestr+")"
   end
 locn
 end
end
