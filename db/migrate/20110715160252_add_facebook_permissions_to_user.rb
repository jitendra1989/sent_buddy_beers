class AddFacebookPermissionsToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :facebook_permissions, :text
  end

  def self.down
    remove_column :users, :facebook_permissions
  end
end
