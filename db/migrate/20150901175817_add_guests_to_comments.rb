class AddGuestsToComments < ActiveRecord::Migration
  def change
    change_table :comments do |t|
      t.string :fromName
      t.string :fromEmail
      t.boolean :approved
      t.string :auth_digest
    end
  end
end
