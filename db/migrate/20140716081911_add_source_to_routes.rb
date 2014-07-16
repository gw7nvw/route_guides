class AddSourceToRoutes < ActiveRecord::Migration
  def change
       change_table :routes do |t|
        t.string :datasource
       end

  end

end
