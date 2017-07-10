class CreateCatchments < ActiveRecord::Migration
  def change
    create_table :catchments do |t|
      t.string :name
      t.integer :nzreach
      t.integer :order
      t.polygon :boundary, :spatial => true, :srid => 4326
      t.point :outflow,  :spatial => true, :srid => 4326
      t.timestamps
    end
  end
end
