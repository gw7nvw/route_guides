class ChangeProjenctionInPlaneInstances < ActiveRecord::Migration
  def change
     change_table(:place_instances) do |t|
       t.remove :projn
       t.integer :projection_id
     end

  end
end
