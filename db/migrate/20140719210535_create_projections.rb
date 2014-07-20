class CreateProjections < ActiveRecord::Migration
  def change
    create_table :projections do |t|
       t.string :name
       t.string :proj4
       t.string :wkt
       t.integer :epsg
       t.timestamps
    end
  end
end
