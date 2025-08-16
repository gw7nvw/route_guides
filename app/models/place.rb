class Place < ActiveRecord::Base
  has_many :placeInstances
  has_many :placeIndices
  belongs_to :createdBy, class_name: "User"
  belongs_to :updatedBy, class_name: "User"
  belongs_to :projection
  validates :createdBy, :presence => true
  validates :experienced_at, :presence => true

  validates :name, presence: true
  validates :place_type, presence: true
  validates :location, presence: true
  validates :x, presence: true
  validates :y, presence: true
  validates :projection, presence: true 
  before_save :default_values
  after_create :do_beenthere


  # But use a geographic implementation for the :lonlat column.
  set_rgeo_factory_for_column(:location, RGeo::Geographic.spherical_factory(:srid => 4326, :proj4=> '+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs'))

def isDest
    (self.placeType.isDest  or self.adjoiningRoutes.count<2)
end

#will be populated with merged place_id when merging is supported for places
def history_id
  'place-'+self.id.to_s
end

def merged_from
  nil
end

def merged_into
  nil
end

def placeType
  t=PlaceType.find_by_sql ["select * from place_types where name=?",self.place_type]
  t.first
end

def firstexperienced_at
     t=Place.find_by_sql ["select created_at, experienced_at from place_instances  
                where place_id = ? order by created_at limit 1", self.id]
     t.first.try(:experienced_at) || "1900-01-01".to_datetime
end

def firstcreated_at
     t=Place.find_by_sql ["select min(pd.created_at) id from place_instances pd 
                where pd.place_id = ?", self.id]
     tt=t.first.try(:id) || self.created_at 
     tt.localtime()
end

def revision_number
     t=Place.find_by_sql ["select count(id) id from place_instances ri 
                 where ri.place_id = ? and ri.updated_at <= ?",self.id, self.updated_at]
     t.first.try(:id)
end


def default_values
    self.created_at ||= self.updated_at
    if self.updated_at_changed? then
      self.affected_at = self.updated_at
    else
      self.affected_at =Time.new()
    end
end

def create_new_instance
     place_instance=PlaceInstance.new(self.attributes.except('affected_at', 'created_at', 'updated_at'))
     place_instance.place_id=self.id
     place_instance.id=nil
     place_instance.createdBy_id = self.updatedBy_id #current_user.id

     place_instance.save   
end

def adjoiningRoutesWithLinks

  pls=[self.id]; self.linked('place').each do |pl| pls+=[pl.item_id] end
  ars=self.adjoiningRoutes
  allars=[]

  ars.each do |ar|
    allars=allars+[ar]
    ar.linked('place').each do |l|
      if !(pls.include? l.item_id) then 
        nr=ar.dup
        nr.id=ar.id
        nr.endplace_id=l.item_id
        allars=allars+[nr]
      end
    end
  end
  allars
end

def adjoiningRoutes
   #routes using us
   t=Route.find_by_sql ["select *  from routes where startplace_id = ? and published=true", self.id]
   t2=Route.find_by_sql ["select *  from routes where endplace_id = ? and published=true",self.id]
   t2.each do |ti|
     t=t+[ti.reverse]
   end
   
   self.links.each do |l|
     #routes from places linked to us
     if l.item_type=="place" then
         pl2=Place.find_by_id(l.item_id)
         lt=Route.find_by_sql ["select *  from routes where startplace_id = ? and published=true", l.item_id]
         lt2=Route.find_by_sql ["select *  from routes where endplace_id = ? and published=true", l.item_id]
         t=t+lt
         lt2.each do |ti|
            t=t+[ti.reverse]
         end
         #routes linked to linked place  
         pl2.linked('route').each do |ll|
             lr=Route.find_by_signed_id(ll.item_id)
             lr2=Route.find_by_signed_id(-ll.item_id)
             if lr then t=t+[lr] end
             if lr2 then t=t+[lr2] end
         end
     end

     #routes linked to us
     if l.item_type=="route" then
         lr=Route.find_by_signed_id(l.item_id)
         lr2=Route.find_by_signed_id(-l.item_id)
         if lr then t=t+[lr] end 
         if lr2 then t=t+[lr2] end 
     end
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
  if placeb then 
     pbstr=placeb.to_s
     pb=Place.find_by_id(placeb)
     lps=pb.linked('place')
     if lps.count>0 then
       lps.each do |lp|
         pbstr=pbstr+", "+lp.item_id.to_s
       end
     end         
     queryString+=" and endplace_id in ("+pbstr+")" 
  end
  if destOnly then queryString+=%q[ and "isdest" = true and direct = true] end
  if baseRoute then queryString+=" and url contains '"+baseRoute[:url]+"'" end
  if ignoreRoute then queryString+=" and not url contains '"+ignoreRoute+"'" end

  ris=RouteIndex.find_by_sql [queryString]

   #routes using linked places
   self.links.each do |l|
     if l.item_type=="place" then
       queryString="select * from route_indices where startplace_id = "+l.item_id.to_s
        if placeb then queryString+=" and endplace_id in ("+pbstr+")" end
        if destOnly then queryString+=%q[ and "isdest" = true and direct = true] end
        if baseRoute then queryString+=" and url contains '"+baseRoute[:url]+"'" end
        if ignoreRoute then queryString+=" and not url contains '"+ignoreRoute+"'" end
            
        ris2=RouteIndex.find_by_sql [queryString]
        ris=ris+ris2
     end
   end

   ris
end


def adjoiningPlaces(placeb, destOnly, maxHopCount, baseRoute, ignoreRoute)
  if !maxHopCount then maxHopCount=12 end

  if ignoreRoute then 
      ir=Route.find_by_signed_id(ignoreRoute)
      ignorePlace=[ir.startplace_id, ir.endplace_id] 
  else ignorePlace=nil end
  if placeb then 
     pbarr=[placeb]
     pb=Place.find_by_id(placeb)
     lps=pb.linked('place')
     if lps.count>0 then
       lps.each do |lp|
         pbarr=pbarr+[lp.item_id]
       end
     end         
  end
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


  #if a base route is supplied, use that as the start of our route search
  if baseRoute
    urlSoFar[0]=baseRoute[:url]
    urlindex=0
    routeStr=baseRoute[:url].split('x')[1..-1]
    routeStr.each do |rs|
      if rs[0]=='r' or rs[0]=='q' then 
         if rs[0]=='r' then
           thisRoute=rs[2..-1].to_i
           currentLeg=Route.find_by_signed_id(thisRoute)
           placeSoFar[0]=[currentLeg.endplace_id]+placeSoFar[0]
           currentDirect=(currentLeg.endplace.isLocatedAtHut)
         else
           rtarr=rs[2..-1].split('y')
           if rtarr.count<3 then abort() end
           thisRoute=rtarr[0].to_i
           currentLeg=Route.find_by_signed_id(thisRoute)
           placeSoFar[0]=[rtarr[2].to_i]+placeSoFar[0] 
           nextPlace=Place.find_by_id(rtarr[2].to_i)
           currentDirect=(nextPlace.isLocatedAtHut)
         end
         routeSoFar[0]=[thisRoute]+routeSoFar[0] 
         urlindex+=1
         thisDistance[0]=thisDistance[0]+(currentLeg.distance or 0)
         thisTime[0]=thisTime[0]+(currentLeg.time or 0)
         lastIsDirect=thisIsDirect[0]

         thisIsDirect[0]= !(!thisIsDirect[0] or currentDirect)
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
    if ((placeb and (pbarr.include? nextDest.id)) or (!placeb and  nextDest.isDest)  or (!placeb and lastIsDirect)) then
         goodRoute[goodPathCount]={
              :place => nextDest.id, 
              :placelist => placeSoFar[0],
              :route=>routeSoFar[0], 
              :url=>urlSoFar[0],
              :direct => lastIsDirect,
              :distance => thisDistance[0],
              :time => thisTime[0],
              :altgain => thisAltGain[0],
              :altloss => thisAltLoss[0],
              :minalt => thisMinAlt[0],
              :maxalt => thisMaxAlt[0],
              :maxroutetype => thisMaxRouteType[0],
              :maximportance => thisMaxImportance[0],
              :maxgradient => thisMaxGradient[0],
              :maxterrain => thisMaxTerrain[0],
              :maxalpines => thisMaxAlpineS[0],
              :maxalpinew => thisMaxAlpineW[0],
              :maxriver => thisMaxRiver[0],
              :avgimportance => thisSumImportance[0]/thisDistance[0],
              :avgroutetype => thisSumRouteType[0]/thisDistance[0],
              :avggradient => thisSumGradient[0]/thisDistance[0],
              :avgterrain => thisSumTerrain[0]/thisDistance[0],
              :avgalpines => thisSumAlpineS[0]/thisDistance[0],
              :avgalpinew => thisSumAlpineW[0]/thisDistance[0],
              :avgriver => thisSumRiver[0]/thisDistance[0]
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
      here.adjoiningRoutesWithLinks.each do |ar|
        if ar.id.abs != (ignoreRoute or 0).abs then
          matchedThisRoute=false
          endOfLine=false
          nextDest=ar.endplace
          # only use if not already in route, and is not start of the ignoreRoute
          beenThere=false
          if (thisPath.include? nextDest.id) then 
              beenThere=true 
          end
          nextDest.links.each do |l|
            if l.item_type=="place" then
              if (thisPath.include? l.item_id) then 
                beenThere=true 
              end 
            end
          end
          #check for 
          if (routeSoFar[currentRouteIndex].include? ar.id) or (routeSoFar[currentRouteIndex].include? -ar.id) then 
            beenThere=true 
          end

          if (!beenThere) and (!ignorePlace or !(ignorePlace.include? nextDest.id)) then
             #big hack to check if endpoint weve been given is same as saved route. If not is an intermediate point
             oldr=Route.find_by_signed_id(ar.id)
             if oldr then oldep=oldr.endplace_id else oldep=0 end
             prefix="xrv"
             suffix=""
             #do not process backwards routes between intermediate points ... will result in duplicates
             if !(ar.startplace_id!=here.id and ar.endplace_id!=oldep and ar.id<0) then
     
             
               if ar.startplace_id!=here.id or  ar.endplace_id!=oldep then
                 prefix="xqv"
                 suffix="y"+here.id.to_s+"y"+ar.endplace_id.to_s
               end
   
               if ((placeb and (pbarr.include? nextDest.id)) or (!placeb)) then # and  nextDest.isDest) or (!placeb and thisIsDirect[currentRouteIndex])) then
                  tmpDist=thisDistance[currentRouteIndex]+(ar.distance or 0)
                  goodRoute[goodPathCount]=
                       {:place => nextDest.id, 
                        :placelist => [nextDest.id]+thisPath,
                        :route=>[ar.id]+routeSoFar[currentRouteIndex], 
                        :url=>urlSoFar[currentRouteIndex]+prefix+ar.id.to_s+suffix, 
                        :direct => thisIsDirect[currentRouteIndex], 
                        :distance => tmpDist,
                        :time => thisTime[currentRouteIndex]+(ar.time or 0),
                        :altgain => thisAltGain[currentRouteIndex]+ar.altgain,
                        :altloss => thisAltLoss[currentRouteIndex]+ar.altloss,
                        :minalt => [thisMinAlt[currentRouteIndex],(ar.minalt.to_i or 9999)].min,
                        :maxalt => [thisMaxAlt[currentRouteIndex],(ar.maxalt.to_i or 0)].max,
                        :maximportance => [thisMaxImportance[currentRouteIndex],ar.importance_id].max,
                        :maxroutetype => [thisMaxRouteType[currentRouteIndex],ar.routetype_id].max,
                        :maxgradient => [thisMaxGradient[currentRouteIndex],ar.gradient_id].max,
                        :maxterrain => [thisMaxTerrain[currentRouteIndex],ar.terrain_id].max,
                        :maxalpines => [thisMaxAlpineS[currentRouteIndex],ar.alpinesummer_id].max,
                        :maxalpinew => [thisMaxAlpineW[currentRouteIndex],ar.alpinewinter_id].max,
                        :maxriver => [thisMaxRiver[currentRouteIndex],ar.river_id].max,
                        :avgimportance => (thisSumImportance[currentRouteIndex]+ar.importance_id*ar.distance)/tmpDist,
                        :avgroutetype => (thisSumRouteType[currentRouteIndex]+ar.routetype_id*ar.distance)/tmpDist,
                        :avggradient => (thisSumGradient[currentRouteIndex]+ar.gradient_id*ar.distance)/tmpDist,
                        :avgterrain => (thisSumTerrain[currentRouteIndex]+ar.terrain_id*ar.distance)/tmpDist,
                        :avgalpines => (thisSumAlpineS[currentRouteIndex]+ar.alpinesummer_id*ar.distance)/tmpDist,
                        :avgalpinew => (thisSumAlpineW[currentRouteIndex]+ar.alpinewinter_id*ar.distance)/tmpDist, 
                        :avgriver => (thisSumRiver[currentRouteIndex]+ar.river_id*ar.distance)/tmpDist
                  }
                  goodPathCount+=1 
                  goodRoutesFromThisPlace+=1     
                  matchedThisRoute=true
                  endOfLine=(nextDest.isLocatedAtHut)
             end
  
             #only look beyond a destination if destOnly=false
             if endOfLine==false or destOnly==false then
                  nextRouteSoFar[placeCountThisHop]=[ar.id]+routeSoFar[currentRouteIndex]
                  nextUrlSoFar[placeCountThisHop]=urlSoFar[currentRouteIndex]+prefix+ar.id.to_s+suffix
                  nextPlaceSoFar[placeCountThisHop]=[nextDest.id]+thisPath
                  nextDistance[placeCountThisHop]=thisDistance[currentRouteIndex]+(ar.distance or 0)
                  nextTime[placeCountThisHop]=thisTime[currentRouteIndex]+(ar.time or 0)
                  nextIsDirect[placeCountThisHop]=!(!thisIsDirect[currentRouteIndex] or nextDest.isLocatedAtHut)
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
             end # do not process backward routes between 2 intermediate points
          end #if already been there
        end #if ignoreRoute
      end #end of 'each adjoining route' for thisPlace

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

#  goodRoute.sort_by { |hsh| Place.find_by_id(hsh[:place]).name }
   goodRoute

end

def isLocatedAtHut
   lhs=Place.find_by_sql [%[select * from places where id in (select distinct item_id from links l
              where (l."baseItem_type"='place' and l."baseItem_id"=? and item_type='place') 
        union select distinct "baseItem_id" as item_id from links l
              where  (l.item_type='place' and l.item_id=? and "baseItem_type"='place')) and place_type='Hut'], self.id, self.id]
   lhs.count>0 or self.place_type=="Hut" 
end
def isLocatedAtDest
   lhs=Place.find_by_sql [%[select * from places p inner join place_types pt on pt.name=p.place_type where p.id in (select distinct item_id from links l
              where (l."baseItem_type"='place' and l."baseItem_id"=? and item_type='place') 
        union select distinct "baseItem_id" as item_id from links l
              where  (l.item_type='place' and l.item_id=? and "baseItem_type"='place')) and pt."isDest"=true], self.id, self.id]
    (lhs.count>0 or self.placeType.isDest  or self.adjoiningRoutes.count<2)
end

def trips
   t=Place.find_by_sql ["select distinct t.* from trips t
       inner join trip_details td on td.trip_id = t.id
       where td.place_id = ? and t.published=true",self.id]
end

def links
   r=Link.find_by_sql [%q[select distinct id, item_id, item_type, item_url from links l
              where (l."baseItem_type"='place' and l."baseItem_id"=?) 
        union (select distinct id, "baseItem_id" as item_id, "baseItem_type" as item_type, '' as item_url from links l 
              where  (l.item_type='place' and l.item_id=?))],self.id, self.id]
end

def linked(type)
   r=Link.find_by_sql [%q[select distinct id, item_id, item_type, item_url from links l
              where (l."baseItem_type"='place' and l."baseItem_id"=? and item_type=?) 
        union select distinct id, "baseItem_id" as item_id, "baseItem_type" as item_type, '' as item_url from links l
              where  (l.item_type='place' and l.item_id=? and "baseItem_type"=?)],self.id, type, self.id, type]
end

def park
   hs=Crownparks.find_by_sql [ %q[select * from crownparks p where ST_Contains(p."WKT",ST_GeomFromText(']+self.location.as_text+%q[',4326)) limit 1; ] ]
   hs.first
end 

def do_beenthere
  if self.experienced_at and self.experienced_at > "1950-01-01".to_date then
    add_beenthere(self.updatedBy_id)
  end
end

def add_beenthere(user_id)
    if self.experienced_at!=nil then
          beenthere = Beenthere.new
          beenthere.place_id = self.id
          beenthere.user_id=self.updatedBy_id
          dup=Beenthere.find_by_sql [ "select id from beentheres where user_id="+beenthere.user_id.to_s+" and place_id="+beenthere.place_id.to_s ]
          if dup.count==0 then 
              beenthere.save
              true
          else
              false
          end
  end
end

def beenthere(user_id)
    dup=Beenthere.find_by_sql [ "select id from beentheres where user_id="+user_id.to_s+" and place_id="+self.id.to_s ]
    if dup and dup.count>0 then true else false end
end

end
