class CreateTripDetails < ActiveRecord::Migration
  def change
    create_table :trip_details do |t|
      t.integer :trip_id
      t.integer :place_id
      t.integer :route_id
      t.integer :direction
      t.boolean :showForward
      t.boolean :showReverse
      t.integer :order

      t.timestamps
    end
  end
end
