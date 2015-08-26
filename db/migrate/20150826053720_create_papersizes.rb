class CreatePapersizes < ActiveRecord::Migration
  def change
    create_table :papersizes do |t|
      t.string :name
      t.integer :width
      t.integer :height
      t.timestamps
    end
  end
end
