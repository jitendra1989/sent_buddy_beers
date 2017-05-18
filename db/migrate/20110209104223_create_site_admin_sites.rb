class CreateSiteAdminSites < ActiveRecord::Migration
  def self.up
    create_table :site_admin_sites do |t|
      t.integer :site_id
      t.integer :site_admin_id

      t.timestamps
    end
  end

  def self.down
    drop_table :site_admin_sites
  end
end
