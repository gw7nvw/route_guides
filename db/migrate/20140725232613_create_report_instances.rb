class CreateReportInstances < ActiveRecord::Migration
  def change
    create_table :report_instances do |t|
      t.integer :report_id
      t.string :name
      t.text :description
      t.integer :createdBy_id

      t.timestamps
    end
  end
end
