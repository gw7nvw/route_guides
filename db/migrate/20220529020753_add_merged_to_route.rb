class AddMergedToRoute < ActiveRecord::Migration
  def change
   add_column :route_instances, :merged_into_id, :integer
   add_column :route_instances, :merged_from_id, :integer

  end
end
