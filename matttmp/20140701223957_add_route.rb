class AddRoute < ActiveRecord::Migration
  def change
    create_table :routes do |t|
      t.string :name
      t.text :description
      t.integer :routetype_id
      t.integer :gradient
      t.integer :terrain_veg
      t.integer :alpine_summer
      t.integer :rivers
      t.integer :apline_winter
      t.text :winter_description
      t.integer :start_place
      t.integer :end_place
      t.text :links
      t.integer :createdBy_id
      t.timestamps
    end
  end
end
