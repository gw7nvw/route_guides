class AddPublishedToRoutes < ActiveRecord::Migration
  def change
       change_table :routes do |t|
         t.boolean :published
       end
       change_table :route_instances do |t|
         t.boolean :published
       end

  end
end
