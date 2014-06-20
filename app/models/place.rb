class Place < ActiveRecord::Base
  has_many :placeInstances
  belongs_to :createdBy, class_name: "User"
  validates :createdBy, :presence => true

  validates :name, presence: true
  validates :location, presence: true

  # But use a geographic implementation for the :lonlat column.
  set_rgeo_factory_for_column(:location, RGeo::Geographic.spherical_factory(:srid => 4326, :proj4=> '+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs'))
end
