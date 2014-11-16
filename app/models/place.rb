class Place < ActiveRecord::Base
  has_many :placeInstances
  has_many :placeIndices
  belongs_to :createdBy, class_name: "User"
  belongs_to :updatedBy, class_name: "User"
  belongs_to :projection
  validates :createdBy, :presence => true
  validates :experienced_at, :presence => true

  validates :name, presence: true
  validates :location, presence: true
  validates :x, presence: true
  validates :y, presence: true
  validates :projection, presence: true 
  before_save :default_values
  after_save :create_new_instance


  # But use a geographic implementation for the :lonlat column.
  set_rgeo_factory_for_column(:location, RGeo::Geographic.spherical_factory(:srid => 4326, :proj4=> '+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs'))

def placeType
  t=PlaceType.find_by_sql ["select * from place_types where name=?",self.place_type]
  t.first
end

def firstexperienced_at
     t=Place.find_by_sql ["select created_at, experienced_at from place_instances  
                where place_id = ? order by created_at limit 1", self.id]
     t.first.try(:experienced_at)
end

def firstcreated_at
     t=Place.find_by_sql ["select min(pd.created_at) id from place_instances pd 
                where pd.place_id = ?", self.id]
     t.first.try(:id)

end

def revision_number
     t=Place.find_by_sql ["select count(id) id from place_instances ri 
                 where ri.place_id = ? and ri.updated_at <= ?",self.id, self.updated_at]
     t.first.try(:id)
end


def default_values
    self.created_at ||= self.updated_at
end

def create_new_instance
   place_instance=PlaceInstance.new(self.attributes)
   place_instance.place_id=self.id
   place_instance.id=nil
   place_instance.createdBy_id = self.updatedBy_id #current_user.id

   place_instance.save
end


def adjoiningRoutes
   t=Route.find_by_sql ["select *  from routes where startplace_id = ? and published=true", self.id]
   t2=Route.find_by_sql ["select *  from routes where endplace_id = ? and published=true",self.id]
   t2.each do |ti|
     t=t+[ti.reverse]
   end
   t
end

def adjoiningPlaces(placeb, destOnly, maxHopCount, baseRoute, ignoreRoute)
  if !maxHopCount then maxHopCount=15 end

  placeSoFar=[]
  routeSoFar=[]
  urlSoFar=[]
  placeSoFar[0]=[self.id]
  routeSoFar[0]=[]
  urlSoFar[0]=""
  goodRoute=[]
  placeCountThisHop=1
  hopCount=0
  goodPathCount=0

  #cache placeTypes to avoid loading for each place
  pt=PlaceType.find_by_sql('select name, "isDest" from place_types')

  #if a base route is supplied, use that as the start of our route search
  if baseRoute
    urlSoFar[0]=baseRoute
    routeStr=baseRoute.split('x')[1..-1]
    routeStr.each do |rs|
      if rs[0]=='r' then 
         thisRoute=rs[2..-1].to_i
         routeSoFar[0]=[thisRoute]+routeSoFar[0] 
         #next place is route endplace
         placeSoFar[0]=[Route.find_by_signed_id(thisRoute).endplace_id]+placeSoFar[0]
      end
    end
    hopCount=routeSoFar[0].count

    #add base route, if it meets criteria
    nextDest=Place.find_by_id(placeSoFar[0][0])
    if ((placeb and nextDest.id == placeb) or (!placeb and  pt.select { |pt| pt.name==nextDest.place_type }.first.isDest)) then
         goodRoute[goodPathCount]={:place => nextDest.id, :route=>routeSoFar[0], :url=>urlSoFar[0]}
         goodPathCount+=1
    end
  end #if baseRoute


  while placeCountThisHop>0 and hopCount<maxHopCount do
    hopCount+=1
    currentRouteIndex=0
    nextPlaceSoFar=[]
    nextRouteSoFar=[]
    nextUrlSoFar=[]
    placeCountThisHop=0
    placeSoFar.each do |thisPath|

      #get latets place added to list
      here=Place.find_by_id(thisPath[0])
      goodRoutesFromThisPlace=0

      #add each route to hash
      here.adjoiningRoutes.each do |ar|
        if ar.id.abs != ignoreRoute then
          matchedThisRoute=false
          nextDest=ar.endplace
          if !thisPath.include? nextDest.id then
             if ((placeb and nextDest.id == placeb) or (!placeb and  pt.select { |pt| pt.name==nextDest.place_type }.first.isDest)) then
                  goodRoute[goodPathCount]={:place => nextDest.id, :route=>[ar.id]+routeSoFar[currentRouteIndex], :url=>urlSoFar[currentRouteIndex]+'xrv'+ar.id.to_s}
                  goodPathCount+=1 
                  goodRoutesFromThisPlace+=1     
                  matchedThisRoute=true
             end
  
             #only look beyond a destination if destOnly=false
             if matchedThisRoute==false or destOnly==false then
                  nextRouteSoFar[placeCountThisHop]=[ar.id]+routeSoFar[currentRouteIndex]
                  nextUrlSoFar[placeCountThisHop]=urlSoFar[currentRouteIndex]+'xrv'+ar.id.to_s
                  nextPlaceSoFar[placeCountThisHop]=[nextDest.id]+thisPath
                  placeCountThisHop+=1
                  goodRoutesFromThisPlace+=1
             end
          end
        end #if ignoreRoute
      end #end of 'each adjoining route' for thisPlace

      # if this was a stub route, we're not looking for a specific dest, 
      # add it even if it didn;t end at a destination
      if goodRoutesFromThisPlace==0 and !placeb and routeSoFar[currentRouteIndex].count>0 and !pt.select { |pt| pt.name==here.place_type }.first.isDest then
          goodRoute[goodPathCount]={:place => here.id, :route => routeSoFar[currentRouteIndex], :url => urlSoFar[currentRouteIndex]}
          goodPathCount+=1
      end
      currentRouteIndex+=1
    end # end of for each flace so far

    #replace placesSpFar with new list of latest destinatons found
    placeSoFar=nextPlaceSoFar
    routeSoFar=nextRouteSoFar
    urlSoFar=nextUrlSoFar
  end #end of while we get results & don;t exceed max hop count

  goodRoute

end

def trips
   t=Place.find_by_sql ["select distinct t.* from trips t
       inner join trip_details td on td.trip_id = t.id
       where td.place_id = ? and t.published=true",self.id]
end

def links
   r=Link.find_by_sql [%q[select distinct id, item_id, item_type, item_url from links l
              where (l."baseItem_type"='place' and l."baseItem_id"=?) 
        union select distinct id, "baseItem_id" as item_id, "baseItem_type" as item_type, '' as item_url from links l
              where  (l.item_type='place' and l.item_id=?)],self.id, self.id]
end

def linked(type)
   r=Link.find_by_sql [%q[select distinct id, item_id, item_type, item_url from links l
              where (l."baseItem_type"='place' and l."baseItem_id"=? and item_type=?) 
        union select distinct id, "baseItem_id" as item_id, "baseItem_type" as item_type, '' as item_url from links l
              where  (l.item_type='place' and l.item_id=? and "baseItem_type"=?)],self.id, type, self.id, type]
end



end
