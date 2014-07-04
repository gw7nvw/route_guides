class CreateSecurityoperators < ActiveRecord::Migration
  def change
    create_table :securityoperators do |t|
     t.string :operator
     t.integer :sign
      t.timestamps
    end
  end
end
