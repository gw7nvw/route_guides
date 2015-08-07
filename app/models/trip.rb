class Trip < ActiveRecord::Base
  has_many :trip_details
  validates :name,  presence: true
  belongs_to :createdBy, class_name: "User"

def startplace
  p=nil
  td=TripDetail.where(:trip_id => self.id).order(:order).first
  if td  and td.place_id then
     p=Place.find_by_id(td.place_id)
  end

  if td  and td.route_id then
     r=Route.find_by_signed_id(td.route_id)
     p=r.startplace
  end

  p
end


def endplace
  p=nil
  td=TripDetail.where(:trip_id => self.id).order(:order).last
  if td  and td.place_id then
     p=Place.find_by_id(td.place_id)
  end

  if td  and td.route_id then
     r=Route.find_by_signed_id(td.route_id)
     p=r.endplace
  end

  p
end

def startx
   self.startplace.try('x') || 0
end

def starty
  self.startplace.try('y') || 0
end

def self.find_latest_by_user(count)
  trips=[]
  contributors=Trip.find_by_sql [ 'select "createdBy_id" from trips where published=true group by "createdBy_id" order by max(updated_at) desc limit ?', count ]

  contributors.each do |c|
    r=Trip.find_by_sql [ 'select * from trips where "createdBy_id" = ? and published=true order by updated_at desc limit 1', c.createdBy_id.to_s]
    if r and r.count>0 then trips=trips+r end
  end
  trips
end

def destroy_tree
    success=true
      self.links.each do |l|
         success=success && l.destroy
      end
      self.trip_details.each do |td|
        success=success && td.destroy
      end
      success=success && self.destroy
   success
end

def distance
     t=Trip.find_by_sql ["select sum(r.distance) id from trip_details td 
                inner join routes r on r.id = abs(td.route_id)
                where td.trip_id = ?", self.id]
     t.first.try(:id).to_f
end

def walkingtime
     t=Trip.find_by_sql ["select sum(r.time) id from trip_details td 
                inner join routes r on r.id = abs(td.route_id) 
                where td.trip_id = ?", self.id]
     t.first.try(:id).to_f

end

def to_url
    url=""
    self.trip_details.each do |td|
      url+="xrv"+td.route_id.to_s if td.route_id
      url+="xpv"+td.place_id.to_s if td.place_id
    end
    url
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
