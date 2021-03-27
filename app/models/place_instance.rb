class PlaceInstance < ActiveRecord::Base
  set_rgeo_factory_for_column(:location, RGeo::Geographic.spherical_factory(:srid => 4326))
  belongs_to :place
  belongs_to :createdBy, class_name: "User"
  belongs_to :updatedBy, class_name: "User"

def firstcreated_at
   self.created_at
end

def firstexperienced_at
   self.experienced_at
end

def readable_name
   str=""
   if self.updated_at then str+=self.updated_at.localtime().strftime("%F %T")+" " end
   str+="by "+self.createdBy.name.capitalize
   if self.experienced_at and self.experienced_at.strftime("%F")!="1900-01-01" then str+=". Experienced: "+self.experienced_at.strftime("%F") end
   str
end

def revision_number
     t=PlaceInstance.find_by_sql ["select count(id) id from place_instances ri 
                 where ri.place_id = ? and ri.updated_at <= ?",self.place_id, self.updated_at]
     t.first.try(:id)
end

def self.add_all_beenthere
  pis=PlaceInstance.all
  pis.each do |pi|
    if pi.place and pi.experienced_at and pi.experienced_at > "1950-01-01".to_date then 
      pi.place.add_beenthere(pi.createdBy_id)
    end
  end
end
  
end
