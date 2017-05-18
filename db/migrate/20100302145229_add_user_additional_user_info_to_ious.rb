class AddUserAdditionalUserInfoToIous < ActiveRecord::Migration
  def self.up
    add_column :ious, :recipient_email, :string
    add_column :ious, :recipient_facebook_uid, :integer
    rename_column :users, :twitter_handle, :login
    
    user = User.find_by_email("travisjtodd@me.com")
    user.login = "buddybeers"
    user.save(false)
    user = User.find_by_email("hairy@marys.com")
    user.login = "hairymarys"
    user.save(false)
    
    add_index :ious, :recipient_email
    add_index :ious, :recipient_facebook_uid
  end

  def self.down
    remove_column :ious, :recipient_email
    remove_column :ious, :recipient_facebook_uid
    rename_column :users, :login, :twitter_handle
  end
end
