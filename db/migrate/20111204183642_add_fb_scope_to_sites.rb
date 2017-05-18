class AddFbScopeToSites < ActiveRecord::Migration
  def self.up
    add_column :sites, :facebook_app_scope, :text
    Site.all.each { |s| s.update_attribute(:facebook_app_scope, "email, publish_stream, offline_access") }
  end

  def self.down
    remove_column :sites, :facebook_app_scope
  end
end
