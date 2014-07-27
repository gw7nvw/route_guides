class CreateReportLinks < ActiveRecord::Migration
  def change
    create_table :report_links do |t|
      t.integer :place_id
      t.integer :route_id
      t.integer :trip_id
      t.integer :report_id

      t.timestamps
    end
  end
end
