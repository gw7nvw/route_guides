class CreateVisits < ActiveRecord::Migration
  def change
    create_table :visits do |t|
      t.string :visit_type
      t.integer :item_id
      t.integer :user_id

      t.timestamps
    end
  end
end
