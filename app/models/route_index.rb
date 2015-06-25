class RouteIndex < ActiveRecord::Base

  belongs_to :startplace, class_name: "Place"
  belongs_to :endplace, class_name: "Place"

def route
    routeStr=self.url.split('x')[1..-1]
    route=[]
    routeStr.each do |rs|
      if rs[0]=='r' or rs[0]=='q' then
         route=[rs[2..-1].to_i]+route
      end
    end

   route
end

def place
  self.endplace_id
end

def isStub
  #a better plan - look at endplace count during create of index and set isDest=truer
  if self.endplace.adjoiningRoutes.count<2 then true else false   end
end

def maxroutetype_
  mrn=Routetype.find_by_id(self.maxroutetype)
end
def avgroutetype_
  arn=Routetype.find_by_id(self.avgroutetype.to_i)
end
def maxgradient_
  mrn=Gradient.find_by_id(self.maxgradient)
end
def avggradient_
  arn=Gradient.find_by_id(self.avggradient.to_i)
end
def maxriver_
  mrn=River.find_by_id(self.maxriver)
end
def avgriver_
  arn=River.find_by_id(self.avgriver.to_i)
end
def maxalpines_
  mrn=Alpine.find_by_id(self.maxalpines)
end
def avgalpines_
  arn=Alpine.find_by_id(self.avgalpines.to_i)
end
def maxalpinew_
  mrn=Alpinew.find_by_id(self.maxalpinew)
end
def avgalpinew_
  arn=Alpinew.find_by_id(self.avgalpinew.to_i)
end
def maximportance_
  mrn=RouteImportance.find_by_id(self.maximportance)
end
def avgimportance_
  arn=RouteImportance.find_by_id(self.avgimportance.to_i)
end
def maxterrain_
  mrn=Terrain.find_by_id(self.maxterrain)
end
def avgterrain_
  arn=Terrain.find_by_id(self.avgterrain.to_i)
end
end
