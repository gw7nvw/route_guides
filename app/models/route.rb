class Route < ActiveRecord::Base

  has_many :routeInstances
 belongs_to :createdBy, class_name: "User"
 belongs_to :updatedBy, class_name: "User"
  validates :createdBy, :presence => true
#  validates :experienced_at, :presence => true

  validates :via, presence: true
  validates :routetype, presence: true
  belongs_to :routetype
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

  before_save { |route| route.name = route.startplace.name + " to " + route.endplace.name + " via " + route.via }
  validates :name, uniqueness: true
  before_save :default_values
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

   if id<0 then
     route=route.reverse
   end

   route
end

def reverse


   temp=self.startplace_id
   self.startplace_id=self.endplace_id
   self.endplace_id = temp
   self.id=-self.id
   linestr="LINESTRING("
   self.location.points.reverse.each do |p|
     if linestr.length>11 then linestr+="," end
     linestr+=p.x.to_s+" "+p.y.to_s+" "+p.z.to_s
   end
   self.location=linestr+")"


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

   route_instance=RouteInstance.new(route.attributes)
   route_instance.route_id=route.id
   route_instance.id=nil
   route_instance.createdBy_id = route.updatedBy_id #current_user.id

   route_instance.save
end


def firstexperienced_at
     t=Route.find_by_sql ["select created_at, experienced_at from route_instances  
                where route_id = ? order by created_at limit 1", self.id.abs]
     t.first.try(:experienced_at)
end

def firstcreated_at
     t=Route.find_by_sql ["select min(rd.created_at) id from route_instances rd 
                where rd.route_id = ?", self.id.abs]
     t.first.try(:id)

end

def revision_number
     t=Route.find_by_sql ["select count(id) id from route_instances ri 
                 where ri.route_id = ? and ri.updated_at <= ?",self.id.abs, self.updated_at]
     t.first.try(:id)
end

def adjoiningRoutes
   t=Route.find_by_sql ["select distinct *  from routes r 
       where published=true and (startplace_id = ? or endplace_id = ? or startplace_id = ? or endplace_id = ?) and id <> ?",self.startplace_id, self.startplace_id, self.endplace_id, self.endplace_id, self.id.abs]
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
       where td.route_id = ? and t.published=true",self.id.abs]
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
        Resque.enqueue(Indexer,self.id)
end

def regenerate_route_index
  starttime=Time.now()
  maxLegCount=14 #15
  newcount=0

  #delete old entries using this route
  puts "Deleting old entries"
  RouteIndex.where("url ~ ? or url ~ ?",'x[rq]v[-]{0,1}'+self.id.to_s+'x', 'x[rq]v[-]{0,1}'+self.id.to_s+'$').destroy_all

  if self.published==true then
    puts "Finding routes from start: "+(Time.now()-starttime).to_s+" seconds"
    #find all place-to-place routes of length < <maxhops-1> for the start or endplace
    startAffectedRoutes=[{:place => self.startplace.id, :route => [], :url => ''}]+self.startplace.adjoiningPlaces(nil,false,maxLegCount-1, nil,self.id)
    
    rsar=[]
    startAffectedRoutes.each do |ar|
      #routes traversing us start->end
      rar=reverseRouteHash(ar)
      rsar=rsar+[rar]
    end


    puts "Finding routes from end: "+(Time.now()-starttime).to_s+" seconds"
    endAffectedRoutes=[{:place => self.endplace.id, :route => [], :url => ''}]+self.endplace.adjoiningPlaces(nil,false,maxLegCount-1, nil,-self.id)

    rear=[]
    endAffectedRoutes.each do |ar|
      #routes traversing us end->start 
      rar=reverseRouteHash(ar)
      rear=rear+[rar]
    end
  
    #and any linked places
    puts "Finding routes from links: "+(Time.now()-starttime).to_s+" seconds"
    linkedAffectedRoutes=[]
    rlar=[]
    link=0
    self.linked('place').each do |lp|
      linkplace=Place.find_by_id(lp.item_id)
      linkedAffectedRoutes[link]=[{:place => linkplace.id, :route => [], :url => ''}]+linkplace.adjoiningPlaces(nil,false,maxLegCount-1, nil,self.id)

      rlar[link]=[]
      #routes traversing us link->end
      linkedAffectedRoutes[link].each do |ar|
        rar=reverseRouteHash(ar)
        rlar[link]=rlar[link]+[rar]
      end
      link+=1
    end
    
    puts "Generating start<->end: "+(Time.now()-starttime).to_s+" seconds"
    #recalculate all routes from the route's startplace that go via us
    #start <-> end
    ourUrl="xrv"+self.id.to_s 
    rsar.each do |sar|
      endAffectedRoutes.each do |ear|
        fullroute= sar[:url]+ourUrl+ear[:url] 
        if fullroute and fullroute.split('x').count<maxLegCount+1 then
          if (sar[:route].map!(&:abs) & ear[:route].map!(&:abs)).count ==0
            createRI(sar[:startplace],fullroute,ear[:place])
            newcount+=2
          end
 
        end
      end
    end 

    puts "Generating start<->links: "+(Time.now()-starttime).to_s+" seconds"
    #start <-> links   
    link=0
    self.linked('place').each do |lp|
      ourUrl="xqv"+self.id.to_s+"y"+self.startplace_id.to_s+"y"+lp.item_id.to_s
      rsar.each do |sar|
        linkedAffectedRoutes[link].each do |lr|
          fullroute= sar[:url]+ourUrl+lr[:url]
          if fullroute and fullroute.split('x').count<maxLegCount+1 then
            if (sar[:route].map!(&:abs) & lr[:route].map!(&:abs)).count ==0
              createRI(sar[:startplace],fullroute,lr[:place])
              newcount+=2
            end
  
          end
        end
      end
    link+=1
    end

    puts "Generating end<->links: "+(Time.now()-starttime).to_s+" seconds"
    #end <-> links
    link=0
    self.linked('place').each do |lp|
      ourUrl="xqv"+(-self.id).to_s+"y"+self.endplace_id.to_s+"y"+lp.item_id.to_s
      rear.each do |ear|
        linkedAffectedRoutes[link].each do |lr|
          fullroute= ear[:url]+ourUrl+lr[:url]
          if fullroute and fullroute.split('x').count<maxLegCount+1 then
            if (ear[:route].map!(&:abs) & lr[:route].map!(&:abs)).count ==0
              createRI(ear[:startplace],fullroute,lr[:place])
              newcount+=2
            end
  
          end
        end
      end
    link+=1
    end

    puts "Generating links<->links: "+(Time.now()-starttime).to_s+" seconds"
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
                if (lra[:route].map!(&:abs) & lrb[:route].map!(&:abs)).count ==0
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
  puts "Completed: "+newcount.to_s+" routes added/updated in "+(Time.now()-starttime).to_s+" seconds"
end
def createRI(startplace, baseRoute, endplace)
   place=Place.find_by_id(startplace)
   endPlace=Place.find_by_id(endplace)
   isStub=(endPlace.adjoiningRoutes.count<2)
   urlindex=0
   routeStr=baseRoute.split('x')[1..-1]
   routelist=""
   rroutelist=""
   gzrl=""
   lzrl=""
   direct=0
   routeStr.each do |r| 
     nr=r[2..-1].to_i
     routelist+=", "+nr.abs.to_s
     rroutelist+=", "+nr.abs.to_s if r[0]=="r"
     gzrl=gzrl+", "+nr.to_s if nr>0
     lzrl=lzrl+", "+nr.abs.to_s if nr<0
     if  r[0]=='q' then
        rtarr=r[2..-1].split('y')
        nextPlace=Place.find_by_id(rtarr[2].to_i)
        direct+=1 if nextPlace.place_type=="Hut"
     end
   end
   query="select sum(distance) as distance, sum(time) as time, max(maxalt) as maxAlt, min(minalt) as minAlt, max(importance_id) as maxImportance, max(routetype_id) as maxRouteType, max(gradient_id) as maxGradient, max(terrain_id) as maxTerrain, max(alpinesummer_id) as maxAlpineS,  max(alpinewinter_id) as maxAlpineW, max(river_id) as maxRiver,   sum(routetype_id*distance)/sum(distance) as avgRouteType, sum(importance_id*distance)/sum(distance) as avgImportance, sum(gradient_id*distance)/sum(distance) as avgGradient, sum(alpinesummer_id*distance)/sum(distance) as avgAlpineS, sum(alpinewinter_id*distance)/sum(distance) as avgAlpineW, sum(river_id*distance)/sum(distance) as avgRiver from routes where id in ("+routelist[1..-1]+")"
   ri=RouteIndex.new((RouteIndex.find_by_sql [ query ]).first.attributes)

  if rroutelist!="" then 
    query="select count(place_type='Hut') as direct from places p  where p.id in ("+rroutelist[1..-1]+")"
    direct+=(RouteIndex.find_by_sql [ query ]).first.direct
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
  ri.isdest = (endPlace.isDest or isStub)
  ri.fromdest = place.isDest
  ri.url = baseRoute
  p=Place.find_by_id(endPlace.id)
  if p.place_type=="Hut" then direct=direct-1 end
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
           currentDirect=(currentLeg.endplace.place_type=="Hut")
         else
           rtarr=rs[2..-1].split('y')
           if rtarr.count<3 then abort() end
           thisRoute=rtarr[0].to_i
           currentLeg=Route.find_by_signed_id(thisRoute)
           placeSoFar[0]=rtarr[2].to_i+placeSoFar[0]
           nextPlace=Place.find_by_id(rtarr[2].to_i)
           currentDirect=(nextPlace.place_type=="Hut")
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
  puts "Deleting old entries"
  RouteIndex.where("url ~ ? or url ~ ?",'x[rq]v[-]{0,1}'+self.id.to_s+'x', 'x[rq]v[-]{0,1}'+self.id.to_s+'$').destroy_all
  puts "Finding affected places"

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

    puts "Regenerating "+allAR.count.to_s+" routes from affected places via us"
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
  puts "Completed: "+newcount.to_s+" routes added/updated in "+(Time.now()-starttime).to_s+" seconds"
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
     #get endplace (remembering that we need to reverse the last leg direction first)
     rt=routeHash[:route].last
     place=Route.find_by_signed_id(rt).try(:startplace_id)
   else
     place=routeHash[:place]
   end
   {:place => place, :route => route, :url => url, :startplace => routeHash[:place]}
end

def prune_route_index
  #delete old entries using this route
  RouteIndex.where("url ~ ? or url ~ ?",'x[rq]v[-]{0,1}'+self.id.abs.to_s+'x', 'x[rq]v[-]{0,1}'+self.id.abs.to_s+'$').destroy_all
end
end
