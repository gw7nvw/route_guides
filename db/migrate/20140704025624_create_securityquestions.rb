class CreateSecurityquestions < ActiveRecord::Migration
  def change
    create_table :securityquestions do |t|
      t.string :question
      t.integer :answer

      t.timestamps
    end
  end
end
