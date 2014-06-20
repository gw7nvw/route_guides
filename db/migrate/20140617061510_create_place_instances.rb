class CreatePlaceInstances < ActiveRecord::Migration
  def change
    create_table :place_instances do |t|
      t.integer :place_id
      t.string :name
      t.text :description
      t.point :location, :geographic => true, :spatial => true, :srid => 4326
      t.integer :altitude
      t.integer  :createdBy_id
      t.timestamps

    end
  end
end
