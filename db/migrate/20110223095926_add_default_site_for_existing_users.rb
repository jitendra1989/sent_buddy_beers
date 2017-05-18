class AddDefaultSiteForExistingUsers < ActiveRecord::Migration
  def self.up
    User.update_all({:sign_up_site_id => Site.default.id}, {:sign_up_site_id => nil})
  end

  def self.down
  end
end
