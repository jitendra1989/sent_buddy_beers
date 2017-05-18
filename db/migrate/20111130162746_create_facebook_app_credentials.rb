class CreateFacebookAppCredentials < ActiveRecord::Migration
  def self.up
    create_table :facebook_app_credentials do |t|
      t.string :access_token
      t.string :app_id
      t.integer :user_id
      t.integer :site_id
      t.text :permissions

      t.timestamps
    end
    
    add_index :facebook_app_credentials, :user_id
    add_index :facebook_app_credentials, :site_id
    add_index :facebook_app_credentials, :app_id
  end

  def self.down
    drop_table :facebook_app_credentials
  end
end
