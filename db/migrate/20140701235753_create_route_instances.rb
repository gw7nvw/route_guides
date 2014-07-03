class CreateRouteInstances < ActiveRecord::Migration
  def change
    create_table :route_instances do |t|
      t.integer :route_id
      t.string :name
      t.text :description
      t.integer :routetype_id
      t.integer :gradient_id
      t.integer :terrain_id
      t.integer :alpinesummer_id
      t.integer :river_id
      t.integer :alpinewinter_id
      t.text :winterdescription
      t.integer :startplace_id
      t.integer :endplace_id
      t.text :links
      t.integer :createdBy_id
      t.line_string :location, :spatial => true, :srid => 4326

      t.timestamps
    end
  end
end
