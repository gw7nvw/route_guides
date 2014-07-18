class Route < ActiveRecord::Base

  has_many :routeInstances
  belongs_to :createdBy, class_name: "User"
  validates :createdBy, :presence => true

  validates :via, presence: true
  validates :routetype, presence: true
  belongs_to :routetype
  validates :gradient, presence: true
  belongs_to :gradient
  validates :terrain, presence: true
  belongs_to :terrain
  validates :alpinesummer, presence: true
  belongs_to :alpinesummer, class_name: "Alpine"
  validates :alpinewinter, presence: true
  belongs_to :alpinewinter, class_name: "Alpine"
  validates :river, presence: true
  belongs_to :river

  validates :startplace, presence: true
  belongs_to :startplace, class_name: "Place"
  validates :endplace, presence: true
  belongs_to :endplace, class_name: "Place"


  before_save { |route| route.name = route.startplace.name + " to " + route.endplace.name + " via " + route.via }
  before_save :default_values
  set_rgeo_factory_for_column(:location, RGeo::Geographic.spherical_factory(:srid => 4326, :proj4=> '+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs'))


  def default_values
    self.datasource ||= 'drawn on map'
    self.created_at ||= self.updated_at
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

end
