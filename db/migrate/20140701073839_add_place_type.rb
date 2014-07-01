class AddPlaceType < ActiveRecord::Migration
 def change
    create_table :place_types do |t|
      t.string :name
      t.text :description
      t.string :color
      t.string :graphicName
      t.integer :pointRadius
      t.string :url
      t.timestamps
    end
  end
end
