class RouteInstance < ActiveRecord::Base
 belongs_to :route
 belongs_to :createdBy, class_name: "User"
 belongs_to :routetype
 belongs_to :gradient
 belongs_to :terrain
 belongs_to :alpinesummer, class_name: "Alpine"
 belongs_to :alpinewinter, class_name: "Alpinew"
 belongs_to :river
 belongs_to :startplace, class_name: "Place"
 belongs_to :endplace, class_name: "Place"


  set_rgeo_factory_for_column(:location, RGeo::Geographic.spherical_factory(:srid => 4326, :proj4=> '+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs', :has_z_coordinate => true))


def firstcreated_at
   self.created_at
end
def revision_number
     t=RouteInstance.find_by_sql ["select count(id) id from route_instances ri 
                 where ri.route_id = ? and ri.updated_at <= ?",self.route_id, self.updated_at]
     t.first.try(:id)
end


end
