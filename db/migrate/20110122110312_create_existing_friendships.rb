class CreateExistingFriendships < ActiveRecord::Migration
  def self.up
    User.active.each do |user|
      user.ious.each do |iou|
        if iou.sender.present? and iou.recipient.present?
          Friendship.find_or_create_by_user_id_and_friend_id(:user_id => iou.sender_id, :friend_id => iou.recipient_id)
        end
      end
    end
  end

  def self.down
  end
end
