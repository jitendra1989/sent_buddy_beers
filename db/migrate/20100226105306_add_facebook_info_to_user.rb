class AddFacebookInfoToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :fb_uid, :string
    add_column :users, :email_hash, :string, :limit => 64, :null => true
    
    add_index :users, :fb_uid
  end

  def self.down
    remove_column :users, :fb_uid
    remove_column :users, :email_hash
  end
end
