class AddSomeMoreField < ActiveRecord::Migration
  def self.up
    add_column :group_drinks, :expires_at, :datetime 
    add_column :group_drinks, :paid, :boolean, :default => false,  :null => false
    add_column :group_drinks, :notified, :boolean, :default => false,  :null => false
    add_column :group_drinks, :status, :string, :default => "sent", :null => false
    
    add_column :group_drinks, :token, :string
    add_column :group_drinks, :order_id, :integer
    add_column :group_drinks, :promotional, :boolean, :default => false, :null => false
    add_column :group_drinks, :company_promotional, :boolean, :default => false, :null => false
    
    add_column :group_drinks, :paid_at, :datetime
    add_column :group_drinks, :sms_notified_at, :datetime
    add_column :group_drinks, :posted_to_facebook_wall_at, :datetime
    add_column :group_drinks, :posted_to_friends_facebook_wall_at, :datetime
    add_column :group_drinks, :sent_facebook_message_at, :datetime

    
    change_column :group_drinks, :discounted_cents, :integer, :default => 0, :null => false
    change_column :group_drinks, :discounted, :string, :default => false, :null => false
    
    add_column :vouchers, :group_drink_id, :integer
    add_column :facebook_requests, :group_drink_id, :integer
    
  end

  def self.down
    remove_column :group_drinks, :expires_at
    remove_column :group_drinks, :paid
    remove_column :group_drinks, :notified
    remove_column :group_drinks, :status
    
    remove_column :group_drinks, :token
    remove_column :group_drinks, :order_id
    remove_column :group_drinks, :promotional
    remove_column :group_drinks, :company_promotional
    
    remove_column :group_drinks, :paid_at
    remove_column :group_drinks, :sms_notified_at
    remove_column :group_drinks, :posted_to_facebook_wall_at
    remove_column :group_drinks, :posted_to_friends_facebook_wall_at
    remove_column :group_drinks, :sent_facebook_message_at
    
    change_column :group_drinks, :discounted_cents, :integer
    change_column :group_drinks, :discounted, :boolean
    
    remove_column :vouchers, :group_drink_id
    remove_column :facebook_requests, :group_drink_id
  end
end
