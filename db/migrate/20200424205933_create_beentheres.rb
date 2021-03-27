class CreateBeentheres < ActiveRecord::Migration
  def change
    create_table :beentheres do |t|
      t.integer :user_id
      t.integer :place_id
      t.integer :route_id

      t.timestamps
    end
  end
end
