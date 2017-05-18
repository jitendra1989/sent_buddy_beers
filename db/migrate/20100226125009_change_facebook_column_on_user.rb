class ChangeFacebookColumnOnUser < ActiveRecord::Migration
  def self.up
    remove_column :users, :fb_uid
    add_column :users, :facebook_uid, :integer, :limit => 8
    
    add_index :users, :facebook_uid
  end

  def self.down
    remove_column :users, :facebook_uid
    add_column :users, :fb_uid, :string
  end
end
