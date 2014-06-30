class CreatePlaceInstances < ActiveRecord::Migration
  def change
    create_table :place_instances do |t|
      t.integer :place_id
      t.string :name
      t.text :description
      t.point :location,  :spatial => true, :srid => 4326
      t.float :x
      t.float :y
      t.string :projn
      t.integer :altitude
      t.integer  :createdBy_id
      t.timestamps

    end
  end
end
