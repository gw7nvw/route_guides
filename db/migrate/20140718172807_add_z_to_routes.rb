class AddZToRoutes < ActiveRecord::Migration
  def change
     change_table(:routes) do |t|
       t.remove :location
       t.line_string :location,  :spatial => true, :srid => 4326, :has_z => true
  end
end
end
