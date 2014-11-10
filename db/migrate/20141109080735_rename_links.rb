class RenameLinks < ActiveRecord::Migration
 def self.up
    rename_table :report_links, :links
  end

 def self.down
    rename_table :links, :report_links
 end
end
