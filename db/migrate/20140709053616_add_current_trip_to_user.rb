class AddCurrentTripToUser < ActiveRecord::Migration
  def change
       change_table :users do |t|
          t.integer :currenttrip_id
       end

  end
end
