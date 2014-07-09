class Trip < ActiveRecord::Base
   has_many :trip_details

  belongs_to :createdBy, class_name: "User"
  validates :createdBy, :presence => true

end
