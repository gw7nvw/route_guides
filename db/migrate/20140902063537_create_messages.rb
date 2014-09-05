class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :subject
      t.text :message
      t.integer :toUser_id
      t.integer :fromUser_id
      t.integer :forum_id
      t.boolean :hasBeenRead
      t.timestamps
    end
  end
end
