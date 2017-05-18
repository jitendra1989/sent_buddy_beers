class AddFacebookDataToIous < ActiveRecord::Migration
  def self.up
    add_column :ious, :posted_to_facebook_wall_at, :datetime
    add_column :ious, :posted_to_friends_facebook_wall_at, :datetime
    add_column :ious, :sent_facebook_message_at, :datetime
  end

  def self.down
    remove_column :ious, :posted_to_facebook_wall_at
    remove_column :ious, :posted_to_friends_facebook_wall_at
    remove_column :ious, :sent_facebook_message_at
  end
end
