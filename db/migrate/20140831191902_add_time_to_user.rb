class AddTimeToUser < ActiveRecord::Migration
  def change
     change_table :users do |t|
         t.datetime :lastVisited
     end
  end
end
