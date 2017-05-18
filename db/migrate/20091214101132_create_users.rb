class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :twitter_handle
      t.string :sex
      
      # Single Table Inheritance
      t.string :type
      
      # AuthLogic requires and should maintain everything below
      t.boolean :active, :default => false, :null => false
      t.string :crypted_password
      t.string :password_salt
      t.string :persistence_token
      t.string    :single_access_token
      t.string    :perishable_token
      t.integer :login_count, :default => 0 
      t.integer :failed_login_count, :default => 0 
      t.datetime  :last_request_at                                    
      t.datetime  :current_login_at                                   
      t.datetime  :last_login_at                                      
      t.string    :current_login_ip                                   
      t.string    :last_login_ip
      t.timestamps
    end
    
    add_index :users, :name
    add_index :users, :email
    add_index :users, :twitter_handle
  end

  def self.down
    drop_table :users
  end
end
