class AddTypeAndUrlToLinks < ActiveRecord::Migration
  def change
   change_table :links do |t|
      t.string :baseItem_type
   end
  end
end
