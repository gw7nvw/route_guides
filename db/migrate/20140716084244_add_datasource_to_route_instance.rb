class AddDatasourceToRouteInstance < ActiveRecord::Migration
  def change
       change_table :route_instances do |t|
        t.string :datasource
       end
  end
end
