class AddCategoryToPlaceType < ActiveRecord::Migration
  def change
       change_table :place_types do |t|
        t.string :category
       end
  end
end
