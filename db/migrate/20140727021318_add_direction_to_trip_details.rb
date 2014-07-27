class AddDirectionToTripDetails < ActiveRecord::Migration
  def change
       change_table :trip_details do |t|
        t.boolean :is_reverse
       end

  end
end
