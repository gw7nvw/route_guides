class PlaceInstance < ActiveRecord::Base
  set_rgeo_factory_for_column(:location, RGeo::Geographic.spherical_factory(:srid => 4326))
  belongs_to :place
  belongs_to :createdBy, class_name: "User"

def firstcreated_at
   self.created_at
end

def revision_number
     t=PlaceInstance.find_by_sql ["select count(id) id from place_instances ri 
                 where ri.place_id = ? and ri.updated_at <= ?",self.place_id, self.updated_at]
     t.first.try(:id)
end

  
end
