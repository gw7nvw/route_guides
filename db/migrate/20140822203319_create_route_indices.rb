class CreateRouteIndices < ActiveRecord::Migration
  def change
    create_table :route_indices do |t|
      t.integer :startplace_id
      t.integer :endplace_id
      t.boolean :isDest
      t.string :url

      t.timestamps
    end
  end
end
