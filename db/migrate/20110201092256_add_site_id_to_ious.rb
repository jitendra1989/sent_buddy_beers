class AddSiteIdToIous < ActiveRecord::Migration
  def self.up
    add_column :ious, :site_id, :integer
    add_index :ious, :site_id
  end

  def self.down
    remove_column :ious, :site_id
  end
end
