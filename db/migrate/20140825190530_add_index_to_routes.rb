class AddIndexToRoutes < ActiveRecord::Migration
  def change
     add_index :routes, :startplace_id
     add_index :routes, :endplace_id
  end
end
