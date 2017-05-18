class AddFacebookKeysToSites < ActiveRecord::Migration
  def self.up
    add_column :sites, :facebook_app_id, :string
    add_column :sites, :facebook_app_secret, :string
  end

  def self.down
    remove_column :sites, :facebook_app_secret
    remove_column :sites, :facebook_app_id
  end
end
