class Indexer
  @queue = :index
 
  def self.perform(route_id)
     r=Route.find_by_id(route_id)
     if r then r.regenerate_route_index end
  end
end

