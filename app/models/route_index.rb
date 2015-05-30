class RouteIndex < ActiveRecord::Base

  belongs_to :startplace, class_name: "Place"
  belongs_to :endplace, class_name: "Place"

def route
    routeStr=self.url.split('x')[1..-1]
    route=[]
    routeStr.each do |rs|
      if rs[0]=='r' then
         route=[rs[2..-1].to_i]+route
      end
    end

   route
end

def place
  self.endplace_id
end

def maxRouteType_
  mrn=Routetype.find_by_id(self.maxRouteType)
end
def avgRouteType_
  arn=RouteType.find_by_id(self.avgRouteType.to_i)
end
def maxGradient_
  mrn=Gradient.find_by_id(self.maxGradient)
end
def avgGradient_
  arn=Gradient.find_by_id(self.avgGradient.to_i)
end
def maxRiver_
  mrn=River.find_by_id(self.maxRiver)
end
def avgRiver_
  arn=River.find_by_id(self.avgRiver.to_i)
end
def maxAlpineS_
  mrn=Alpine.find_by_id(self.maxAlpineS)
end
def avgAlpineS_
  arn=Alpine.find_by_id(self.avgAlpineS.to_i)
end
def maxAlpineW_
  mrn=Alpinew.find_by_id(self.maxAlpineW)
end
def avgAlpineW_
  arn=Alpinew.find_by_id(self.avgAlpineW.to_i)
end
def maxImportance_
  mrn=RouteImportance.find_by_id(self.maxImportance)
end
def avgImportance_
  arn=RouteImportance.find_by_id(self.avgImportance.to_i)
end
def maxTerrain_
  mrn=Terrain.find_by_id(self.maxTerrain)
end
def avgTerrain_
  arn=Terrain.find_by_id(self.avgTerrain.to_i)
end
end
