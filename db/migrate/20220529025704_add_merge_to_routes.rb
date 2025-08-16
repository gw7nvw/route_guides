class AddMergeToRoutes < ActiveRecord::Migration
  def change
   add_column :routes, :merged_into_id, :integer
   add_column :routes, :merged_from_id, :integer
  end
end
