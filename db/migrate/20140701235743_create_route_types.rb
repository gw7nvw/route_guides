class CreateRouteTypes < ActiveRecord::Migration
  def change
    create_table :routetypes do |t|
      t.string :name, :limit => 40
      t.string :description
      t.integer :difficulty

      t.timestamps
    end
  end
end
