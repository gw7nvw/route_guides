class CreateTrips < ActiveRecord::Migration
  def change
    create_table :trips do |t|
      t.string :name
      t.text :description    
      t.integer :createdBy_id

      t.timestamps
    end
  end
end
