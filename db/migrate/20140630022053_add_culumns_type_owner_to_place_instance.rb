class AddCulumnsTypeOwnerToPlaceInstance < ActiveRecord::Migration
  def change
       change_table :place_instances do |t|
          t.string :place_type, :limit => 20
          t.string :place_owner, :limit => 20
       end
  end
end
