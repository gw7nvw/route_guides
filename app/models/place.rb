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
   t=Place.find_by_sql ["select *  from routes where startplace_id = ? or endplace_id = ?",self.id, self.id]
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
