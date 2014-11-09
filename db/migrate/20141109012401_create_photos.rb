class CreatePhotos < ActiveRecord::Migration
  def change
    create_table :photos do |t|
      t.string :name
      t.string :author
      t.text :description
      t.datetime :taken_at
      t.point :location, :spatial => true, :srid => 4326
      t.point :subject_location, :spatial => true, :srid => 4326
      t.integer  :createdBy_id
      t.timestamps
    end
  end
end
