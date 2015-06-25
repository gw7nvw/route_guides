class AddAltStatsToRoute < ActiveRecord::Migration
  def change
    change_table :routes do |t|
      t.integer :altloss
      t.integer :altgain
      t.integer :minalt
      t.integer :maxalt
    end
    change_table :route_instances do |t|
      t.integer :altloss
      t.integer :altgain
      t.integer :minalt
      t.integer :maxalt
    end

  end
end
