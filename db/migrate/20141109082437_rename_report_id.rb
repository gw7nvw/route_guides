class RenameReportId < ActiveRecord::Migration
  def self.up
    rename_column :links, :report_id, :baseItem_id
  end

  def self.down
    rename_column :links, :baseItem_id, :report_id
    # rename back if you need or do something else or do nothing
  end
end
