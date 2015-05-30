class AddTimeDistDirect < ActiveRecord::Migration
  def change
    add_column :route_indices, :fromDest, :boolean
    add_column :route_indices, :direct, :boolean
    add_column :route_indices, :distance, :decimal
    add_column :route_indices, :time, :decimal
    add_column :route_indices, :altGain, :decimal 
    add_column :route_indices, :altLoss, :decimal 
    add_column :route_indices, :maxImportance, :integer
    add_column :route_indices, :maxRouteType, :integer
    add_column :route_indices, :maxGradient, :integer 
    add_column :route_indices, :maxTerrain, :integer 
    add_column :route_indices, :maxAlpineS, :integer 
    add_column :route_indices, :maxAlpineW, :integer 
    add_column :route_indices, :maxRiver, :integer 
    add_column :route_indices, :avgImportance, :decimal
    add_column :route_indices, :avgRouteType, :decimal
    add_column :route_indices, :avgGradient, :decimal
    add_column :route_indices, :avgTerrain, :decimal
    add_column :route_indices, :avgAlpineS, :decimal
    add_column :route_indices, :avgAlpineW, :decimal
    add_column :route_indices, :avgRiver, :decimal
  end
end
