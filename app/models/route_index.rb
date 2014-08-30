class RouteIndex < ActiveRecord::Base

  belongs_to :startplace, class_name: "Place"
  belongs_to :endplace, class_name: "Place"

end
