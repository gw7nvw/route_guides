class AddPublishAndLenToTrip < ActiveRecord::Migration
  def change
      change_table :trips do |t|
        t.float :lengthmin
        t.float :lengthmax
        t.boolean :published
       end

  end
end
