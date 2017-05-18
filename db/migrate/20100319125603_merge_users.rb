class MergeUsers < ActiveRecord::Migration
  def self.up 
    
    # Create a new email for each user
    User.all.each do |user|
      email = Email.new(:user_id => user.id, :email => user.email, :primary => (user.emails.blank? ? true : false))
      email.save
    end
    
    Email.all.each do |email|
      users = User.find_all_by_email(email.to_s)
      
      # There should only be two active users, because the only way for duplicates is facebook at the moment
      if users.length == 2
        user_1 = users.first
        user_2 = users.last
        user_1.login = user_2.login if user_1.login == user_1.email.parameterize.to_s
        user_1.active = true if user_1.active? or user_2.active? 
        user_1.type = "Customer" if (user_1.type == "Customer" and user_2.type == nil) or (user_2.type == "Customer" and user_1.type == nil)
        user_1.crypted_password = user_2.crypted_password if user_1.crypted_password.blank?
        user_1.password_salt = user_2.password_salt if user_1.password_salt.blank?
        user_1.login_count = user_1.login_count + user_2.login_count
        user_1.facebook_uid = user_2.facebook_uid if user_1.facebook_uid.blank?
        user_1.facebook_session_key = user_2.facebook_session_key if user_1.facebook_session_key.blank?
        user_1.oauth_token = user_2.oauth_token if user_1.oauth_token.blank?
        user_1.oauth_secret = user_2.oauth_secret if user_1.oauth_secret.blank?
        user_1.save(false)
        Iou.find_all_by_sender_id(user_2.id).each do |iou|
          iou.sender_id = user_1.id
          iou.save(false)
        end
        Iou.find_all_by_recipient_id(user_2.id).each do |iou|
          iou.recipient_id = user_1.id
          iou.save(false)
        end
        user_2.destroy()
      end
    end
    
    remove_column :users, :email
  end

  def self.down
    add_column :users, :email, :string
  end
end
