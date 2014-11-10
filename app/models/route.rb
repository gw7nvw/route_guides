class Route < ActiveRecord::Base

  has_many :routeInstances
  belongs_to :createdBy, class_name: "User"
  validates :createdBy, :presence => true

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
   self

end

def default_values
    if !self.datasource or self.datasource.length<1 then
        self.datasource = 'drawn on map'
    end
    self.created_at ||= self.updated_at

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


def firstcreated_at
     t=Route.find_by_sql ["select min(rd.created_at) id from route_instances rd 
                where rd.route_id = ?", self.id]
     t.first.try(:id)

end

def revision_number
     t=Route.find_by_sql ["select count(id) id from route_instances ri 
                 where ri.route_id = ? and ri.updated_at <= ?",self.id, self.updated_at]
     t.first.try(:id)
end

def adjoiningRoutes
   t=Route.find_by_sql ["select distinct *  from routes r 
       where published=true and (startplace_id = ? or endplace_id = ? or startplace_id = ? or endplace_id = ?) and id <> ?",self.startplace_id, self.startplace_id, self.endplace_id, self.endplace_id, self.id.abs]
end

def trips
   t=Route.find_by_sql ["select distinct t.* from trips t
       inner join trip_details td on td.trip_id = t.id
       where td.route_id = ? and t.published=true",self.id]
end
def links
   r=Link.find_by_sql [%q[select distinct id, item_id, item_type, item_url from links l
              where (l."baseItem_type"='route' and l."baseItem_id"=?) 
        union select distinct id, "baseItem_id" as item_id, "baseItem_type" as item_type, '' as item_url from links l
              where  (l.item_type='route' and l.item_id=?)],self.id, self.id]
end

def linked(type)
   r=Link.find_by_sql [%q[select distinct id, item_id, item_type, item_url from links l
              where (l."baseItem_type"='route' and l."baseItem_id"=? and item_type=?) 
        union select distinct id, "baseItem_id" as item_id, "baseItem_type" as item_type, '' as item_url from links l
              where  (l.item_type='route' and l.item_id=? and "baseItem_type"=?)],self.id, type, self.id, type]
end

def reports
   r=Report.find_by_sql [%q[select distinct r.* from reports r
        inner join links rl on (rl."baseItem_id" = r.id and rl."baseItem_type"='report') or (rl.item_id = r.id and rl.item_type='report')
        where (rl.item_type='route' and rl.item_id=?)  or (rl."baseItem_type"='route' and rl."baseItem_id"=?)],self.id, self.id]
end

def maxalt
   alt=0
   if(self.location) then
     self.location.points.each do |p|
       if(p.z)>alt then alt=p.z end
     end
   end
   alt 
end

def minalt
   alt=9999
   if(self.location) then
     self.location.points.each do |p|
       if(p.z)<alt then alt=p.z end
     end
    alt
   else 0
   end
end

def altgain
   alt=0
   if(self.location) then
     lastalt=self.location.points.first.z
     self.location.points.each do |p|
         if(p.z)>lastalt then alt+=p.z-lastalt end
         lastalt=p.z
     end
   end
   alt

end

def altloss
   alt=0
   if(self.location) then
     lastalt=self.location.points.first.z
     self.location.points.each do |p|
       if(p.z)<lastalt then alt+=lastalt-p.z end
       lastalt=p.z
     end
   end
   alt

end

def queue_regenerate_route_index
        Resque.enqueue(Indexer,self.id)
end

def regenerate_route_index
  maxLegCount=15

  #delete old entries using this route
  puts "Deleting ond entries"
  RouteIndex.where("url ~ ? or url ~ ?",'xrv[-]{0,1}'+self.id.to_s+'x', 'xrv[-]{0,1}'+self.id.to_s+'$').destroy_all

  if self.published==true then
    #find all place-to-place routes of length < <maxhops-1> for the start or endplace
    #startAffectedRoutes=[{:place => self.startplace.id}]+self.startplace.adjoiningPlaces(nil,false,maxLegCount-1, nil,self.id)
    if self.startplace.placeType.isDest then startAffectedRoutes=[{:place => self.startplace_id, :route => [], :url => ''}]
    else startAffectedRoutes=[] end
    startAffectedRoutes+=self.startplace.adjoiningPlaces(nil,false,maxLegCount-1, nil,self.id)
    #endAffectedRoutes=[{:place => self.endplace.id}]+self.endplace.adjoiningPlaces(nil,false,maxLegCount-1, nil,self.id)
    if self.endplace.placeType.isDest then endAffectedRoutes=[{:place => self.endplace_id, :route => [], :url => ''}]
    else endAffectedRoutes=[] end
    endAffectedRoutes+=self.endplace.adjoiningPlaces(nil,false,maxLegCount-1, nil,self.id)
  
    #reverse the above routes (so get them TO us, no FROM us) 
    #and add the leg we are saving to the end of the route
    rsar=[]
    startAffectedRoutes.each do |ar|
      rar=reverseRouteHash(ar)
      rar[:url]=rar[:url]+"xrv"+self.id.to_s
      rar[:route]=[self.id]+rar[:route]
      rar[:place]=self.endplace.id
      rar[:startplace]=ar[:place]
      rsar=rsar+[rar]
    end
  
    rear=[]
    endAffectedRoutes.each do |ar|
  
      rar=reverseRouteHash(ar)
      rar[:url]=rar[:url]+"xrv"+(-self.id).to_s
      rar[:route]=[-self.id]+rar[:route]
      rar[:place]=self.startplace.id
      rar[:startplace]=ar[:place]
      rear=rear+[rar]
    end
  
    allAR=rsar+rear
    #recalculate all routes from the route's startplace that go via us
    allAR.each do |ar|
      #get start place
      place=Place.find_by_id(ar[:startplace])
  
      #regernarate routes from place using this route as base-route   
      newRoutes=place.adjoiningPlaces(nil,false,maxLegCount,ar[:url],nil)
      puts "Newroutes"
       
       newRoutes.each do |newRoute|
          puts newRoute[:url]
          endPlace_id=newRoute[:place]
          endPlace=Place.find_by_id(endPlace_id)
  
          if RouteIndex.where("url = ?",newRoute[:url]).count==0 and place.id!=endPlace.id then
            ri=RouteIndex.new(:startplace_id => place.id, :endplace_id => endPlace.id, :isDest => endPlace.placeType.isDest, :url => newRoute[:url])
            ri.save
          end
       end
    end  
  end
end


def reverseRouteHash(routeHash)
   route=[]
   url=""
   if routeHash[:route].count>0 then 
     routeHash[:route].each do |rt|
       route=[-rt]+route
       url=url+"xrv"+(-rt).to_s
     end
     #get endplace (remembering that we need to reverse the last leg direction first)
     rt=routeHash[:route].last
     place=Route.find_by_signed_id(rt).try(:startplace_id)
   else
     place=routeHash[:place]
   end
   {:place => place, :route => route, :url => url}
end

def prune_route_index
  #delete old entries using this route
  RouteIndex.where("url ~ ? or url ~ ?",'xrv[-]{0,1}'+self.id.abs.to_s+'x', 'xrv[-]{0,1}'+self.id.abs.to_s+'$').destroy_all
end
end
