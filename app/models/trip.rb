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

def reports
   r=Report.find_by_sql ["select distinct r.* from reports r
        inner join report_links rl on rl.report_id = r.id
        where rl.item_type='trip' and rl.item_id=?",self.id]
end

end
