class CreatePlaces < ActiveRecord::Migration
  def change
    create_table :places do |t|
      t.string :name
      t.text :description
      t.point :location, :geographic => true, :spatial => true, :srid => 4326
      t.float :x
      t.float :y
      t.projn :string
      t.integer :altitude
      t.integer  :createdBy_id
      t.timestamps
    end
  end
end
