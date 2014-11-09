class AddXyToPhotos < ActiveRecord::Migration
  def change
       change_table :photos do |t|
      t.float :x
      t.float :y
      t.integer :projection_id
       end

  end
end
