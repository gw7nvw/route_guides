class AddMinimiseToTrip < ActiveRecord::Migration
  def change
      change_table :trip_details do |t|
        t.boolean :showConditions
	t.boolean :showLinks
       end

  end
end
