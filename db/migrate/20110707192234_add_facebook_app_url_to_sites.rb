class AddFacebookAppUrlToSites < ActiveRecord::Migration
  def self.up
    add_column :sites, :facebook_app_url, :string
  end

  def self.down
    remove_column :sites, :facebook_app_url
  end
end
