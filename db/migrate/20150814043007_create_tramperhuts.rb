class CreateTramperhuts < ActiveRecord::Migration
  def change
    create_table :tramperhuts do |t|
      t.string :name
      t.string :url
      t.point :location, :spatial => true, :srid => 4326
      t.integer :place_id
      t.integer  :distance
    end
  end
end
