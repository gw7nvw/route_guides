class AddUncertaintyToRouteIndices < ActiveRecord::Migration
  def change
    add_column :route_indices, :distError, :decimal
    add_column :route_indices, :timeError, :decimal
    add_index :route_indices, :startplace_id
    add_index :route_indices, :endplace_id
  end
end
