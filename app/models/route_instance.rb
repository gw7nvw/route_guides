class RouteInstance < ActiveRecord::Base
 belongs_to :route
 belongs_to :createdBy, class_name: "User"
 belongs_to :updatedBy, class_name: "User"
 belongs_to :routetype
 belongs_to :gradient
 belongs_to :terrain
 belongs_to :alpinesummer, class_name: "Alpine"
 belongs_to :alpinewinter, class_name: "Alpinew"
 belongs_to :river
 belongs_to :startplace, class_name: "Place"
 belongs_to :endplace, class_name: "Place"
 belongs_to :importance, class_name: "RouteImportance"


  set_rgeo_factory_for_column(:location, RGeo::Geographic.spherical_factory(:srid => 4326, :proj4=> '+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs', :has_z_coordinate => true))


def firstcreated_at
   self.created_at
end

def firstexperienced_at
   self.experienced_at
end

def revision_number
     t=RouteInstance.find_by_sql ["select count(id) id from route_instances ri 
                 where ri.route_id = ? and ri.updated_at <= ?",self.route_id, self.updated_at]
     t.first.try(:id)
end

def readable_name
   str=""
   if self.updated_at then str+=self.updated_at.localtime().strftime("%F %T")+" " end
   if self.createdBy then str+="by "+self.createdBy.name.capitalize end
   if self.experienced_at and self.experienced_at.strftime("%F")!="1900-01-01" then str+=". Experienced: "+self.experienced_at.strftime("%F") end
   if str=="" then str=self.id.to_s end
   str
end

def self.add_all_beenthere
  ris=RouteInstance.all
  ris.each do |ri|
    if ri.route and ri.experienced_at and ri.experienced_at > "1950-01-01".to_date then
      ri.route.add_beenthere(ri.createdBy_id)
    end
  end
end

end
