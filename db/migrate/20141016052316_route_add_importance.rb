class RouteAddImportance < ActiveRecord::Migration
  def change
       change_table :routes do |t|
         t.integer :importance_id
       end
       change_table :route_instances do |t|
         t.integer :importance_id
       end
  end
end
