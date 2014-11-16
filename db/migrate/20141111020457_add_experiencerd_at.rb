class AddExperiencerdAt < ActiveRecord::Migration
  def change
   change_table :routes do |t|
      t.date :experienced_at
   end
   change_table :route_instances do |t|
      t.date :experienced_at
   end
   change_table :places do |t|
      t.date :experienced_at
   end
   change_table :place_instances do |t|
      t.date :experienced_at
   end
   change_table :trips do |t|
      t.date :experienced_at
   end
  end
end
