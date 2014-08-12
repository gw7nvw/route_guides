class CreateReportLinks < ActiveRecord::Migration
  def change
    create_table :report_links do |t|
      t.integer :item_id
      t.string :item_type
      t.integer :report_id

      t.timestamps
    end
  end
end
