class AddAffectedAtToPlace < ActiveRecord::Migration
  def change
    change_table :places do |t|
      t.datetime :affected_at
    end
  end
end
