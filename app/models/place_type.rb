class PlaceType < ActiveRecord::Base

  validates :name, presence: true

end
