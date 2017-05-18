class AuthlogicToDevise < ActiveRecord::Migration
  def self.up
    add_column :users, :confirmation_token, :string
    add_column :users, :confirmed_at, :datetime
    add_column :users, :confirmation_sent_at, :datetime
    User.reset_column_information
    User.find_each do |user|
      if user.read_attribute(:active)
        user.update_attribute(:confirmed_at, Time.now)
      else
        user.update_attribute(:confirmation_token, user.perishable_token)
        user.update_attribute(:confirmation_sent_at, Time.now)
      end
    end

    change_table :users do |t|
      t.rename :crypted_password, :encrypted_password
      t.rename :login_count, :sign_in_count
      t.rename :last_login_at, :last_sign_in_at
      t.rename :current_login_at, :current_sign_in_at
      t.rename :current_login_ip, :current_sign_in_ip
      t.rename :last_login_ip, :last_sign_in_ip

      t.remove :last_request_at, :persistence_token, :perishable_token, :single_access_token, :active

      t.string :reset_password_token, :remember_token
      t.datetime :remember_created_at
    end
  end

  def self.down
    add_column :users, :perishable_token, :string
    add_column :users, :active, :boolean, :default => false
    User.reset_column_information
    User.find_each do |user|
      user.update_attribute(:perishable_token, user.confirmation_token)
      user.update_attribute(:active, true) if user.confirmed_at
    end

    change_table :users do |t|
      t.rename :encrypted_password, :crypted_password
      t.rename :sign_in_count, :login_count
      t.rename :last_sign_in_at, :last_login_at
      t.rename :current_sign_in_at, :current_login_at
      t.rename :current_sign_in_ip, :current_login_ip
      t.rename :last_sign_in_ip, :last_login_ip

      t.datetime :last_request_at
      t.string :persistence_token, :single_access_token

      t.remove :reset_password_token, :remember_token, :remember_created_at, :confirmation_token, :confirmed_at, :confirmation_sent_at
    end
  end
end
