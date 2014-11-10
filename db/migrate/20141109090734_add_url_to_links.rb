class AddUrlToLinks < ActiveRecord::Migration
  def change
   change_table :links do |t|
      t.string :item_url
   end

  end
end
