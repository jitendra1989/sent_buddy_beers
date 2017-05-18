require 'test_helper'

class FriendshipTest < ActiveSupport::TestCase

  should belong_to(:user)
  should belong_to(:friend)

  should validate_presence_of(:user_id)
  should validate_presence_of(:friend_id)

  should "validate friend is not the user" do
    @friendship = Friendship.create(:user_id => 1, :friend_id => 1)
    assert @friendship.new_record?
    assert @friendship.errors.present?
  end

  context "a friendship" do
    setup do
      @user1 = Factory(:user)
      @user2 = Factory(:user)
      @friendship = Factory(:friendship, :user => @user1, :friend => @user2)
    end

    should "have the reciprocal friendship created" do
      assert Friendship.all.length == 2
      assert @user2.friends.include?(@user1)
    end
  end
end
