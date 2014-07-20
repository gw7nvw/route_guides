class AddStyleToRouteType < ActiveRecord::Migration
  def change
   change_table :routetypes do |t|
     t.string :code
     t.string :linecolor
     t.string :linetype
   end
  end
end
