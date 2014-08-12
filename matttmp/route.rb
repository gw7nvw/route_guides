class Route < ActiveRecord::Base
  has_many :route_instances
  belongs_to :createdBy, class_name: "User"
  validates :createdBy, :presence => true

  validates :name, presence: true
  validates :routeType, presence: true
  has_one :routeType
  validates :start_place, presence: true
  validates :end_place, presence: true
  validates :projn, presence: true

end
