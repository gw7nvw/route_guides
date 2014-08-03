class AddIsDestToPlaceType < ActiveRecord::Migration
  def change
       change_table :place_types do |t|
        t.boolean :isDest
       end
  end
end
