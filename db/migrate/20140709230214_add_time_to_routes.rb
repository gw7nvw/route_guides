class AddTimeToRoutes < ActiveRecord::Migration
  def change
       change_table :routes do |t|
          t.decimal :time
          t.decimal :distance
       end
       change_table :route_instances do |t|
          t.decimal :time
          t.decimal :distance
       end


  end
end
