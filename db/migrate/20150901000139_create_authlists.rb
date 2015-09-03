class CreateAuthlists < ActiveRecord::Migration
  def change
    create_table :authlists do |t|
      t.string :address
      t.string :name
      t.boolean :allow, :default => false
      t.boolean :forbid, :default => false
      t.timestamps
      t.string :auth_digest
    end
  end
end
