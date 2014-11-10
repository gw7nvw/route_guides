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
   r=Report.find_by_sql [%q[select distinct r.* from reports r
        inner join links rl on (rl."baseItem_id" = r.id and rl."baseItem_type"='report') or (rl.item_id = r.id and rl.item_type='report')
        where (rl.item_type='trip' and rl.item_id=?)  or (rl."baseItem_type"='trip' and rl."baseItem_id"=?)],self.id, self.id]
end

def links
   r=Link.find_by_sql [%q[select distinct id, item_id, item_type, item_url from links l
              where (l."baseItem_type"='trip' and l."baseItem_id"=?) 
        union select distinct id, "baseItem_id" as item_id, "baseItem_type" as item_type, '' as item_url from links l
              where  (l.item_type='trip' and l.item_id=?)],self.id, self.id]
end

def linked(type)
   l=Link.find_by_sql [%q[select distinct id, item_id, item_type, item_url from links l
              where (l."baseItem_type"='trip' and l."baseItem_id"=? and item_type=?) 
        union select distinct id, "baseItem_id" as item_id, "baseItem_type" as item_type, '' as item_url from links l
              where  (l.item_type='trip' and l.item_id=? and "baseItem_type"=?)],self.id, type, self.id, type]


end

end
