class CreateRouteImportances < ActiveRecord::Migration
  def change
    create_table :route_importances do |t|
      t.string :name
      t.string :description
      t.integer :importance
      t.boolean :isprimary
      t.timestamps
    end
  end
end
