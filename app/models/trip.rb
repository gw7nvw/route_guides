class Trip < ActiveRecord::Base
   has_many :trip_details

  belongs_to :createdBy, class_name: "User"
  validates :createdBy, :presence => true

def distance
     t=Trip.find_by_sql ["select sum(r.distance) id from trip_details td 
                inner join routes r on r.id = td.route_id 
                where td.trip_id = ?", self.id]
     t.first.try(:id).to_f
end

def walkingtime
     t=Trip.find_by_sql ["select sum(r.time) id from trip_details td 
                inner join routes r on r.id = td.route_id 
                where td.trip_id = ?", self.id]
     t.first.try(:id).to_f


end

end
