class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.string :name
      t.text :description
      t.integer :createdBy_id

      t.timestamps
    end
  end
end
