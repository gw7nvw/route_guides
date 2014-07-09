class AddViaFieldToRoute < ActiveRecord::Migration
  def change
       change_table :routes do |t|
          t.string :via 
          t.text :reverse_description
       end

  end
end
