class AddCulumnsTypeOwnerToPlace < ActiveRecord::Migration
  def change
       change_table :places do |t|
          t.string :place_type, :limit => 20
          t.string :place_owner, :limit => 20
       end
  end
end
