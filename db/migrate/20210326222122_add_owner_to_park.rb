class AddOwnerToPark < ActiveRecord::Migration
  def change
   add_column :parks, :owner, :string

  end
end
