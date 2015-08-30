class CreateRouteclasses < ActiveRecord::Migration
  def change
    create_table :routeclasses do |t|
       t.string :name
       t.string :description
    end
  end
end
