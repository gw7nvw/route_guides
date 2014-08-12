class Place < ActiveRecord::Base
  has_many :placeInstances
  belongs_to :createdBy, class_name: "User"
  belongs_to :projection
  validates :createdBy, :presence => true

  validates :name, presence: true
  validates :location, presence: true
  validates :x, presence: true
  validates :y, presence: true
  validates :projection, presence: true 
  before_save :default_values

  # But use a geographic implementation for the :lonlat column.
  set_rgeo_factory_for_column(:location, RGeo::Geographic.spherical_factory(:srid => 4326, :proj4=> '+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs'))

def placeType
  t=PlaceType.find_by_sql ["select * from place_types where name=?",self.place_type]
  t.first
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

def adjoiningRoutes
   t=Route.find_by_sql ["select *  from routes where startplace_id = ? or endplace_id = ?",self.id, self.id]
end

def adjoiningPlaces
  maxLegCount=20

  validDest=Array.new
   placeSoFar=[]
  routeSoFar=[]
  urlSoFar=[]
  placeSoFar[0]=[self.id]
  routeSoFar[0]=[]
  urlSoFar[0]=""
  goodPath=[]
  goodRoute=[]
  destFound=1
  legCount=0
  goodPathCount=0

  while destFound>0 and legCount<maxLegCount do

    legCount+=1
    loopCount=0
    nextPlaceSoFar=[]
    nextRouteSoFar=[]
    nextUrlSoFar=[]
    destFound=0
    placeSoFar.each do |thisPath|

      #get latets place added to list
      here=Place.find_by_id(thisPath[0])
      totalFound=0

      #add each route to hash
      here.adjoiningRoutes.each do |ar|
        if ar.endplace_id==here.id then
          nextDest=ar.startplace
          direction=-1
        else
          nextDest=ar.endplace
          direction=1
        end

        if nextDest.placeType.isDest and !thisPath.include? nextDest.id then
                goodPath[goodPathCount]=[nextDest.id]+thisPath
                goodRoute[goodPathCount]={:place => nextDest.id, :route=>[direction*ar.id]+routeSoFar[loopCount], :url=>urlSoFar[loopCount]+'_r'+(direction*ar.id).to_s}
                goodPathCount+=1 
                totalFound+=1     
        else
          if !thisPath.include? nextDest.id then
                nextRouteSoFar[destFound]=[direction*ar.id]+routeSoFar[loopCount]
                nextUrlSoFar[destFound]=urlSoFar[loopCount]+'_r'+(direction*ar.id).to_s
                nextPlaceSoFar[destFound]=[nextDest.id]+thisPath
                destFound+=1
                totalFound+=1
          end
        end
      end #end of 'each adjoining route' for thisPlace
      # if this was a stub route, add it even if it didn;t end at a destination
      if totalFound==0  and routeSoFar[loopCount].count>0 then
                goodPath[goodPathCount]=thisPath
                goodRoute[goodPathCount]={:place => here.id, :route => routeSoFar[loopCount], :url => urlSoFar[loopCount]}
                goodPathCount+=1
      end
      loopCount+=1
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

def reports
   r=Report.find_by_sql ["select distinct r.* from reports r
        inner join report_links rl on rl.report_id = r.id
        where rl.item_type='place' and rl.item_id=?",self.id]
end

end
