class AddAltMaxMinToIndex < ActiveRecord::Migration
  def change
    add_column :route_indices, :minAlt, :integer
    add_column :route_indices, :maxAlt, :integer
  end
end
