class RouteType < ActiveRecord::Base
  belongs_to :route
  validates :name,  presence: true
  validates :difficulty,  presence: true
end
