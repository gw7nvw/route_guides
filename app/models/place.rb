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

def adjoiningPlaceListFast()
   aps=adjoiningPlacesFast(nil,true,nil,nil,nil)
   places=[]
   aps.each do |ap| 
      if ap[:direct] then places=places+[Place.find_by_id(ap[:endplace_id])] end
   end
   if places and places.count>0 then places.uniq.sort_by{|a| [a.name]} else [] end
end

def adjoiningPlacesFast(placeb, destOnly, maxHopCount, baseRoute, ignoreRoute)

  queryString="select * from route_indices where startplace_id = "+self.id.to_s
  if placeb then queryString+=" and endplace_id = "+placeb.to_s end
  if destOnly then queryString+=%q[ and "isDest" = true and direct = true] end
  if baseRoute then queryString+=" and url contains '"+baseRoute+"'" end
  if ignoreRoute then queryString+=" and not url contains '"+baseRoute+"'" end

  ris=RouteIndex.find_by_sql [queryString]

end

def adjoiningPlaces(placeb, destOnly, maxHopCount, baseRoute, ignoreRoute)
  if !maxHopCount then maxHopCount=15 end

  if ignoreRoute then 
      ir=Route.find_by_signed_id(ignoreRoute)
      ignorePlace=[ir.startplace_id, ir.endplace_id] 
  else ignorePlace=nil end
  placeSoFar=[]
  routeSoFar=[]
  urlSoFar=[]
  thisTime=[]
  thisDistance=[]
  thisIsDirect=[]
  thisAltGain=[]
  thisAltLoss=[]
  thisMaxAlt=[]
  thisMinAlt=[]
  thisMaxImportance=[]
  thisMaxRouteType=[]
  thisMaxGradient=[]
  thisMaxTerrain=[]
  thisMaxAlpineS=[]
  thisMaxAlpineW=[]
  thisMaxRiver=[]
  thisSumImportance=[]
  thisSumRouteType=[]
  thisSumGradient=[]
  thisSumTerrain=[]
  thisSumAlpineS=[]
  thisSumAlpineW=[]
  thisSumRiver=[]

  placeSoFar[0]=[self.id]
  routeSoFar[0]=[]
  urlSoFar[0]=""
  thisTime[0]=0
  thisDistance[0]=0
  thisIsDirect[0]=true
  lastIsDirect=true
  thisAltGain[0]=0
  thisAltLoss[0]=0
  thisMaxAlt[0]=0
  thisMinAlt[0]=9999
  thisMaxImportance[0]=0
  thisMaxRouteType[0]=0
  thisMaxGradient[0]=0
  thisMaxTerrain[0]=0
  thisMaxAlpineS[0]=0
  thisMaxAlpineW[0]=0
  thisMaxRiver[0]=0
  thisSumImportance[0]=0
  thisSumRouteType[0]=0
  thisSumGradient[0]=0
  thisSumTerrain[0]=0
  thisSumAlpineS[0]=0
  thisSumAlpineW[0]=0
  thisSumRiver[0]=0
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
         currentLeg=Route.find_by_signed_id(thisRoute)
         placeSoFar[0]=[currentLeg.endplace_id]+placeSoFar[0]
         thisDistance[0]=thisDistance[0]+(currentLeg.distance or 0)
         thisTime[0]=thisTime[0]+(currentLeg.time or 0)
         lastIsDirect=thisIsDirect[0]
         thisIsDirect[0]= !(!thisIsDirect[0] or (currentLeg.endplace.place_type=="Hut"))
         thisAltGain[0]=thisAltGain[0]+currentLeg.altgain
         thisAltLoss[0]=thisAltLoss[0]+currentLeg.altloss
         thisMaxAlt[0]=[thisMaxAlt[0],(currentLeg.maxalt.to_i or 0)].max
         thisMinAlt[0]=[thisMinAlt[0],(currentLeg.minalt.to_i or 9999)].min
         thisMaxImportance[0]=[thisMaxImportance[0],currentLeg.importance_id].max
         thisMaxRouteType[0]=[thisMaxRouteType[0],currentLeg.routetype_id].max
         thisMaxGradient[0]=[thisMaxGradient[0],currentLeg.gradient_id].max
         thisMaxTerrain[0]=[thisMaxTerrain[0],currentLeg.terrain_id].max
         thisMaxAlpineS[0]=[thisMaxAlpineS[0],currentLeg.alpinesummer_id].max
         thisMaxAlpineW[0]=[thisMaxAlpineW[0],currentLeg.alpinewinter_id].max
         thisMaxRiver[0]=[thisMaxRiver[0],currentLeg.river_id].max
         thisSumImportance[0]=thisSumImportance[0]+currentLeg.importance_id*currentLeg.distance
         thisSumRouteType[0]=thisSumRouteType[0]+currentLeg.routetype_id*currentLeg.distance
         thisSumGradient[0]=thisSumGradient[0]+currentLeg.gradient_id*currentLeg.distance
         thisSumTerrain[0]=thisSumTerrain[0]+currentLeg.terrain_id*currentLeg.distance
         thisSumAlpineS[0]=thisSumAlpineS[0]+currentLeg.alpinesummer_id*currentLeg.distance
         thisSumAlpineW[0]=thisSumAlpineW[0]+currentLeg.alpinewinter_id*currentLeg.distance
         thisSumRiver[0]=thisSumRiver[0]+currentLeg.river_id*currentLeg.distance
      end
    end
    hopCount=routeSoFar[0].count

    #add base route, if it meets criteria
    # 1) This is th enbd place we are looking for
    # 2) We are not looking for a specific place, and this is a 'destination'
    # 3) We are not looking for a placex, and this is a direct route 
    nextDest=Place.find_by_id(placeSoFar[0][0])
    if ((placeb and nextDest.id == placeb) or (!placeb and  pt.select { |pt| pt.name==nextDest.place_type }.first.isDest)  or (!placeb and lastIsDirect)) then
         goodRoute[goodPathCount]={
              :place => nextDest.id, 
              :route=>routeSoFar[0], 
              :url=>urlSoFar[0],
              :direct => lastIsDirect,
              :distance => thisDistance[0],
              :time => thisTime[0],
              :altGain => thisAltGain[0],
              :altLoss => thisAltLoss[0],
              :minAlt => thisMinAlt[0],
              :maxAlt => thisMaxAlt[0],
              :maxRouteType => thisMaxRouteType[0],
              :maxImportance => thisMaxImportance[0],
              :maxGradient => thisMaxGradient[0],
              :maxTerrain => thisMaxTerrain[0],
              :maxAlpineS => thisMaxAlpineS[0],
              :maxAlpineW => thisMaxAlpineW[0],
              :maxRiver => thisMaxRiver[0],
              :avgImportance => thisSumImportance[0]/thisDistance[0],
              :avgRouteType => thisSumRouteType[0]/thisDistance[0],
              :avgGradient => thisSumGradient[0]/thisDistance[0],
              :avgTerrain => thisSumTerrain[0]/thisDistance[0],
              :avgAlpineS => thisSumAlpineS[0]/thisDistance[0],
              :avgAlpineW => thisSumAlpineW[0]/thisDistance[0],
              :avgRiver => thisSumRiver[0]/thisDistance[0]
         }
         goodPathCount+=1
    end
  end #if baseRoute


  while placeCountThisHop>0 and hopCount<maxHopCount do
    hopCount+=1
    currentRouteIndex=0
    nextPlaceSoFar=[]
    nextRouteSoFar=[]
    nextUrlSoFar=[]
    nextTime=[]
    nextDistance=[]
    nextIsDirect=[]
    nextAltGain=[]
    nextAltLoss=[]
    nextMinAlt=[]
    nextMaxAlt=[]
    nextMaxImportance=[]
    nextMaxRouteType=[]
    nextMaxGradient=[]
    nextMaxTerrain=[]
    nextMaxAlpineS=[]
    nextMaxAlpineW=[]
    nextMaxRiver=[]
    nextSumImportance=[]
    nextSumRouteType=[]
    nextSumGradient=[]
    nextSumTerrain=[]
    nextSumAlpineS=[]
    nextSumAlpineW=[]
    nextSumRiver=[]
    placeCountThisHop=0
    placeSoFar.each do |thisPath|

      #get latets place added to list
      here=Place.find_by_id(thisPath[0])
      goodRoutesFromThisPlace=0

      #add each route to hash
      here.adjoiningRoutes.each do |ar|
        if ar.id.abs != (ignoreRoute or 0).abs then
          matchedThisRoute=false
          endOfLine=false
          nextDest=ar.endplace
          # only use if not already in route, and is not start of the ignoreRoute
          if (!thisPath.include? nextDest.id) and (!ignorePlace or !(ignorePlace.include? nextDest.id)) then
             #puts "==="
             #puts baseRoute
             #puts [nextDest.id]+thisPath
             #puts urlSoFar[currentRouteIndex]+'xrv'+ar.id.to_s
             if ((placeb and nextDest.id == placeb) or (!placeb and  pt.select { |pt| pt.name==nextDest.place_type }.first.isDest) or (!placeb and thisIsDirect[currentRouteIndex])) then
                  tmpDist=thisDistance[currentRouteIndex]+(ar.distance or 0)
                  goodRoute[goodPathCount]=
                       {:place => nextDest.id, 
                        :route=>[ar.id]+routeSoFar[currentRouteIndex], 
                        :url=>urlSoFar[currentRouteIndex]+'xrv'+ar.id.to_s, 
                        :direct => thisIsDirect[currentRouteIndex], 
                        :distance => tmpDist,
                        :time => thisTime[currentRouteIndex]+(ar.time or 0),
                        :altGain => thisAltGain[currentRouteIndex]+ar.altgain,
                        :altLoss => thisAltLoss[currentRouteIndex]+ar.altloss,
                        :minAlt => [thisMinAlt[currentRouteIndex],(ar.minalt.to_i or 9999)].min,
                        :maxAlt => [thisMaxAlt[currentRouteIndex],(ar.maxalt.to_i or 0)].max,
                        :maxImportance => [thisMaxImportance[currentRouteIndex],ar.importance_id].max,
                        :maxRouteType => [thisMaxRouteType[currentRouteIndex],ar.routetype_id].max,
                        :maxGradient => [thisMaxGradient[currentRouteIndex],ar.gradient_id].max,
                        :maxTerrain => [thisMaxTerrain[currentRouteIndex],ar.terrain_id].max,
                        :maxAlpineS => [thisMaxAlpineS[currentRouteIndex],ar.alpinesummer_id].max,
                        :maxAlpineW => [thisMaxAlpineW[currentRouteIndex],ar.alpinewinter_id].max,
                        :maxRiver => [thisMaxRiver[currentRouteIndex],ar.river_id].max,
                        :avgImportance => (thisSumImportance[currentRouteIndex]+ar.importance_id*ar.distance)/tmpDist,
                        :avgRouteType => (thisSumRouteType[currentRouteIndex]+ar.routetype_id*ar.distance)/tmpDist,
                        :avgGradient => (thisSumGradient[currentRouteIndex]+ar.gradient_id*ar.distance)/tmpDist,
                        :avgTerrain => (thisSumTerrain[currentRouteIndex]+ar.terrain_id*ar.distance)/tmpDist,
                        :avgAlpineS => (thisSumAlpineS[currentRouteIndex]+ar.alpinesummer_id*ar.distance)/tmpDist,
                        :avgAlpineW => (thisSumAlpineW[currentRouteIndex]+ar.alpinewinter_id*ar.distance)/tmpDist, 
                        :avgRiver => (thisSumRiver[currentRouteIndex]+ar.river_id*ar.distance)/tmpDist
                  }
                  goodPathCount+=1 
                  goodRoutesFromThisPlace+=1     
                  matchedThisRoute=true
                  endOfLine=(nextDest.place_type=="Hut")
             end
  
             #only look beyond a destination if destOnly=false
             if endOfLine==false or destOnly==false then
                  nextRouteSoFar[placeCountThisHop]=[ar.id]+routeSoFar[currentRouteIndex]
                  nextUrlSoFar[placeCountThisHop]=urlSoFar[currentRouteIndex]+'xrv'+ar.id.to_s
                  nextPlaceSoFar[placeCountThisHop]=[nextDest.id]+thisPath
                  nextDistance[placeCountThisHop]=thisDistance[currentRouteIndex]+(ar.distance or 0)
                  nextTime[placeCountThisHop]=thisTime[currentRouteIndex]+(ar.time or 0)
                  nextIsDirect[placeCountThisHop]=!(!thisIsDirect[currentRouteIndex] or nextDest.place_type=="Hut")
                  nextAltGain[placeCountThisHop]=thisAltGain[currentRouteIndex]+ar.altgain
                  nextAltLoss[placeCountThisHop]=thisAltLoss[currentRouteIndex]+ar.altloss
                  nextMinAlt[placeCountThisHop]=[thisMinAlt[currentRouteIndex],(ar.minalt.to_i or 9999)].min
                  nextMaxAlt[placeCountThisHop]=[thisMaxAlt[currentRouteIndex],(ar.maxalt.to_i or 0)].max
                  nextMaxImportance[placeCountThisHop]=[thisMaxImportance[currentRouteIndex],ar.importance_id].max
                  nextMaxRouteType[placeCountThisHop]=[thisMaxRouteType[currentRouteIndex],ar.routetype_id].max
                  nextMaxGradient[placeCountThisHop]=[thisMaxGradient[currentRouteIndex],ar.gradient_id].max
                  nextMaxTerrain[placeCountThisHop]=[thisMaxTerrain[currentRouteIndex],ar.terrain_id].max
                  nextMaxAlpineS[placeCountThisHop]=[thisMaxAlpineS[currentRouteIndex],ar.alpinesummer_id].max
		  nextMaxAlpineW[placeCountThisHop]=[thisMaxAlpineW[currentRouteIndex],ar.alpinewinter_id].max
                  nextMaxRiver[placeCountThisHop]=[thisMaxRiver[currentRouteIndex],ar.river_id].max
                  nextSumImportance[placeCountThisHop]=thisSumImportance[currentRouteIndex]+ar.importance_id*ar.distance
                  nextSumRouteType[placeCountThisHop]=thisSumRouteType[currentRouteIndex]+ar.routetype_id*ar.distance
                  nextSumGradient[placeCountThisHop]=thisSumGradient[currentRouteIndex]+ar.gradient_id*ar.distance
                  nextSumTerrain[placeCountThisHop]=thisSumTerrain[currentRouteIndex]+ar.terrain_id*ar.distance
                  nextSumAlpineS[placeCountThisHop]=thisSumAlpineS[currentRouteIndex]+ar.alpinesummer_id*ar.distance
		  nextSumAlpineW[placeCountThisHop]=thisSumAlpineW[currentRouteIndex]+ar.alpinewinter_id*ar.distance
                  nextSumRiver[placeCountThisHop]=thisSumRiver[currentRouteIndex]+ar.river_id*ar.distance


                  placeCountThisHop+=1
                  goodRoutesFromThisPlace+=1
             end
          end
        end #if ignoreRoute
      end #end of 'each adjoining route' for thisPlace

      # if this was a stub route, we're not looking for a specific dest, 
      # add it even if it didn;t end at a destination
      if goodRoutesFromThisPlace==0 and !placeb and routeSoFar[currentRouteIndex].count>0 and !pt.select { |pt| pt.name==here.place_type }.first.isDest then
          goodRoute[goodPathCount]=
                       {:place => here.id, 
                        :route=>routeSoFar[currentRouteIndex], 
                        :url=>urlSoFar[currentRouteIndex],
                        :direct => thisIsDirect[currentRouteIndex], 
                        :distance => thisDistance[currentRouteIndex],
                        :time => thisTime[currentRouteIndex],
                        :altGain => thisAltGain[currentRouteIndex],
                        :altLoss => thisAltLoss[currentRouteIndex],
                        :maxAlt => thisMaxAlt[currentRouteIndex],
                        :minAlt => thisMinAlt[currentRouteIndex],
                        :maxImportance => thisMaxImportance[currentRouteIndex],
                        :maxRouteType => thisMaxRouteType[currentRouteIndex],
                        :maxGradient => thisMaxGradient[currentRouteIndex],
                        :maxTerrain => thisMaxTerrain[currentRouteIndex],
                        :maxAlpineS => thisMaxAlpineS[currentRouteIndex],
                        :maxAlpineW => thisMaxAlpineW[currentRouteIndex],
                        :maxRiver => thisMaxRiver[currentRouteIndex],
                        :avgImportance => (thisSumImportance[currentRouteIndex])/thisDistance[currentRouteIndex],
                        :avgRouteType => (thisSumRouteType[currentRouteIndex])/thisDistance[currentRouteIndex],
                        :avgGradient => (thisSumGradient[currentRouteIndex])/thisDistance[currentRouteIndex],
                        :avgTerrain => (thisSumTerrain[currentRouteIndex])/thisDistance[currentRouteIndex],
                        :avgAlpineS => (thisSumAlpineS[currentRouteIndex])/thisDistance[currentRouteIndex],
                        :avgAlpineW => (thisSumAlpineW[currentRouteIndex])/thisDistance[currentRouteIndex], 
                        :avgRiver => (thisSumRiver[currentRouteIndex])/thisDistance[currentRouteIndex]
                       }
          goodPathCount+=1
      end
      currentRouteIndex+=1
    end # end of for each flace so far

    #replace placesSpFar with new list of latest destinatons found
    placeSoFar=nextPlaceSoFar
    routeSoFar=nextRouteSoFar
    urlSoFar=nextUrlSoFar
    thisTime=nextTime
    thisDistance=nextDistance
    thisIsDirect=nextIsDirect
    thisAltGain=nextAltGain
    thisAltLoss=nextAltLoss
    thisMaxAlt=nextMaxAlt
    thisMinAlt=nextMinAlt
    thisMaxRouteType=nextMaxRouteType
    thisMaxImportance=nextMaxImportance
    thisMaxGradient=nextMaxGradient
    thisMaxTerrain=nextMaxTerrain
    thisMaxAlpineS=nextMaxAlpineS
    thisMaxAlpineW=nextMaxAlpineW
    thisMaxRiver=nextMaxRiver
    thisSumImportance=nextSumImportance
    thisSumRouteType=nextSumRouteType
    thisSumGradient=nextSumGradient
    thisSumTerrain=nextSumTerrain
    thisSumAlpineS=nextSumAlpineS
    thisSumAlpineW=nextSumAlpineW
    thisSumRiver=nextSumRiver
 
  end #end of while we get results & don;t exceed max hop count

  goodRoute.sort_by { |hsh| Place.find_by_id(hsh[:place]).name }

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
