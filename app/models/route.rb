class Route < ActiveRecord::Base

  has_many :routeInstances
  belongs_to :createdBy, class_name: "User"
  validates :createdBy, :presence => true

  validates :name, presence: true
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


  set_rgeo_factory_for_column(:location, RGeo::Geographic.spherical_factory(:srid => 4326, :proj4=> '+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs'))
end
