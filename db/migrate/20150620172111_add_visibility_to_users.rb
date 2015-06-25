class AddVisibilityToUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.boolean :hide_name
    end
  end
end
