class AddUpdatedByToEverything < ActiveRecord::Migration
  def change
       change_table :places do |t|
         t.integer :updatedBy_id
       end
       change_table :place_instances do |t|
         t.integer :updatedBy_id
       end
       change_table :routes do |t|
         t.integer :updatedBy_id
       end
       change_table :route_instances do |t|
         t.integer :updatedBy_id
       end
       change_table :reports do |t|
         t.integer :updatedBy_id
       end
       change_table :report_instances do |t|
         t.integer :updatedBy_id
       end
  end
end
