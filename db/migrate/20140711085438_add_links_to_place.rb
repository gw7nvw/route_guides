class AddLinksToPlace < ActiveRecord::Migration
  def change
       change_table :places do |t|
          t.text :links
       end
       change_table :place_instances do |t|
          t.text :links

       end

  end
end
