class RenameRouteindexColumns < ActiveRecord::Migration
  def self.up
     rename_column :route_indices, :maxAlt, :maxalt
     rename_column :route_indices, :minAlt, :minalt
     rename_column :route_indices, :isDest, :isdest
     rename_column :route_indices, :fromDest, :fromdest
     rename_column :route_indices, :altGain, :altgain
     rename_column :route_indices, :altLoss, :altloss
     rename_column :route_indices, :maxImportance, :maximportance
     rename_column :route_indices, :maxRouteType, :maxroutetype
     rename_column :route_indices, :maxGradient, :maxgradient
     rename_column :route_indices, :maxTerrain, :maxterrain
     rename_column :route_indices, :maxAlpineS, :maxalpines
     rename_column :route_indices, :maxAlpineW, :maxalpinew
     rename_column :route_indices, :maxRiver, :maxriver
     rename_column :route_indices, :avgImportance, :avgimportance
     rename_column :route_indices, :avgRouteType, :avgroutetype
     rename_column :route_indices, :avgGradient, :avggradient
     rename_column :route_indices, :avgTerrain, :avgterrain
     rename_column :route_indices, :avgAlpineS, :avgalpines
     rename_column :route_indices, :avgAlpineW, :avgalpinew
     rename_column :route_indices, :avgRiver, :avgriver
     rename_column :route_indices, :distError, :disterror
     rename_column :route_indices, :timeError, :timeerror
  end

  def self.down
     rename_column :route_indices, :maxalt, :maxAlt 
     rename_column :route_indices, :minalt, :minAlt
     rename_column :route_indices, :isdest, :isDest
     rename_column :route_indices, :fromdest, :fromDest
     rename_column :route_indices, :altgain, :altGain
     rename_column :route_indices, :altloss, :altLoss
     rename_column :route_indices, :maximportance, :maxImportance
     rename_column :route_indices, :maxroutetype, :maxRouteType
     rename_column :route_indices, :maxgradient, :maxGradient
     rename_column :route_indices, :maxterrain, :maxTerrain
     rename_column :route_indices, :maxalpines, :maxAlpineS
     rename_column :route_indices, :maxalpinew, :maxAlpineW
     rename_column :route_indices, :maxriver, :maxRiver
     rename_column :route_indices, :avgimportance, :avgImportance
     rename_column :route_indices, :avgroutetype, :avgRouteType
     rename_column :route_indices, :avggradient, :avgGradient
     rename_column :route_indices, :avgterrain, :avgTerrain
     rename_column :route_indices, :avgalpines, :avgAlpineS
     rename_column :route_indices, :avgalpinew, :avgAlpineW
     rename_column :route_indices, :avgriver, :avgRiver
     rename_column :route_indices, :disterror, :distError
     rename_column :route_indices, :timeerror, :timeError
  end

end
