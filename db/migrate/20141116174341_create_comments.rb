class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.string :item_type
      t.integer :item_id
      t.string :comment
      t.integer :createdBy_id
      t.date :experienced_at

      t.timestamps
    end
  end
end
