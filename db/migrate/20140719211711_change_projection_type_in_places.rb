class ChangeProjectionTypeInPlaces < ActiveRecord::Migration
  def change
     change_table(:places) do |t|
       t.remove :projn
       t.integer :projection_id
     end
  end
end
