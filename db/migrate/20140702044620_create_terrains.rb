class CreateTerrains < ActiveRecord::Migration
  def change
    create_table :terrains do |t|
      t.string :name
      t.string :description
      t.integer :difficulty

      t.timestamps
    end
  end
end
