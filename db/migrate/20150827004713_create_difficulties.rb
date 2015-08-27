class CreateDifficulties < ActiveRecord::Migration
  def change
    create_table :difficulties do |t|
      t.integer :difficulty
      t.string :linecolor
      t.string :linetype
      t.timestamps
    end
  end
end
