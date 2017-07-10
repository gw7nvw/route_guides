class Catchment < ActiveRecord::Base

def places
  places=Place.find_by_sql [ "select * from places where ST_Contains((select boundary from catchments where id=?), location) order by ST_Distance(location,(select outflow from catchments where id=?)); ", self.id, self.id ]
end


def routes
  if self.places.count>0 then
      pl_list="("
    self.places.each do |pl|
      pl_list+=pl.id.to_s+","
    end
    pl_list=pl_list[0..-2]+")"
  else
    pl_list="()"
  end

  routes=Route.find_by_sql [ "select * from routes where published=true and (startplace_id in "+pl_list+" or endplace_id in "+pl_list+")" ]
end

def adjoiningPlaceList
  aps=[]
  self.routes.each do |rt|
    aps+=[rt.startplace_id, rt.endplace_id]
  end
  aps.uniq
end

def route_tree
  if self.routes.count>0 then
   rt_list="("
    self.routes.each do |rt|
      rt_list+=rt.id.to_s+","
    end
    rt_list=rt_list[0..-2]+")"
  else
    rt_list="()"
  end

  aps=[]
  self.places.each do |pl|
    aps+=self.adjoiningPlacesFast(nil,true,nil,nil,nil)
  end

end

end
