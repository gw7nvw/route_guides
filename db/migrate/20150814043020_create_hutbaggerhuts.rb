class CreateHutbaggerhuts < ActiveRecord::Migration
  def change
    create_table :hutbaggerhuts do |t|
      t.string :name
      t.string :url
      t.point :location, :spatial => true, :srid => 4326
      t.integer :place_id
      t.integer  :distance
      t.boolean :removed
      t.timestamps
    end
  end
end
