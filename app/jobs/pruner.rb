class Pruner
  @queue = :index
 
  def self.perform()
     Trip.prune
  end
end

