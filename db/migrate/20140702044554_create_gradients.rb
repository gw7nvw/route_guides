class CreateGradients < ActiveRecord::Migration
  def change
    create_table :gradients do |t|
      t.string :name
      t.string :description
      t.integer :difficulty

      t.timestamps
    end
  end
end
