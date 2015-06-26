class CreateGuests < ActiveRecord::Migration
  def change
    create_table :guests do |t|
      t.string :remember_token
      t.integer :currenttrip_id
      t.timestamps
    end
    add_index  :guests, :remember_token
  end
end
