class AddViaFieldToRouteInstance < ActiveRecord::Migration
  def change
       change_table :route_instances do |t|
          t.string :via 
          t.text :reverse_description

       end

  end
end
