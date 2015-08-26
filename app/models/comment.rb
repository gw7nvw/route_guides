class Comment < ActiveRecord::Base
  belongs_to :createdBy, class_name: "User"
  validates :createdBy, :presence => true
  validates :comment, :presence => true
  validates :item_id, :presence => true
  validates :item_type, :presence => true

  def item
  case self.item_type

  when "place"
    Place.find_by_id(self.item_id) 
  when "route"
    Route.find_by_id(self.item_id)
  when "photo"
    Photo.find_by_id(self.item_id)
  when "trip"
    Trip.find_by_id(self.item_id)
  when "report"
    Report.find_by_id(self.item_id)
  else
    nil
  end

  end
end
