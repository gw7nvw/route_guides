class CreateDochuts < ActiveRecord::Migration
  def change
    create_table :dochuts do |t|
      t.integer :doc_id
      t.string :name
      t.string :url
      t.point :location, :spatial => true, :srid => 4326
      t.integer :place_id
      t.integer  :distance
    end
  end
end
