require 'test_helper'

class FriendshipsControllerTest < ActionController::TestCase

  # friendships/index view
  context "GET to index" do
    setup do
      @user = Factory(:active_user)
      @friend = Factory(:active_user)
    end

    context "when logged out" do
      setup { get :index, :user => Factory.build(:user) }

      should_not assign_to(:current_user)
      should_not assign_to(:friendships)
      should_not assign_to(:user)
      should respond_with(:redirect)
      should set_the_flash.to("You must be logged in to access this page. <a href=\"/users/sign_up\">Click here to create your Buddy Account for free.</a>")
      should redirect_to("the login url"){ new_user_session_url }
    end

    context "when logged in" do
      setup do
        Factory(:friendship, :user => @user, :friend => @friend)
      end

      context "as normal user" do
        setup { assert sign_in(@user) }

        context "and getting to his index page" do
          setup { get :index, :user_id => @user.id}

          should assign_to(:current_user)
          should assign_to(:friendships)
          should assign_to(:user)
          should respond_with(:success)
          should render_template(:index)

          should "only have the user's friendships" do
            assert_equal assigns(:friendships), @user.friendships
          end

          should "have a user that is the current user" do
            assert_equal assigns(:user), assigns(:current_user)
          end
        end

        context "and getting to his index page with a search parameter and rendering as JSON" do
          setup do
            @friend.emails << Factory(:email, :user => @friend)
            get :index, :user_id => @user.id, :q => @friend.email.to_s.first(3), :format => "json"
          end

          should assign_to(:current_user)
          should assign_to(:friendships)
          should assign_to(:friends)
          should assign_to(:user)
          should respond_with_content_type(:json)

          should "have matching user friends" do
            assert assigns(:friends).present?
          end
        end

        context "and getting to his friend's index page" do
          setup { get :index, :user_id => @friend.id}

          should assign_to(:current_user)
          should assign_to(:friendships)
          should assign_to(:user)
          should respond_with(:success)
          should render_template(:index)

          should "only have the user's friendships not his friend's" do
            assert_equal assigns(:friendships), @user.friendships
            assert_not_equal assigns(:friendships), @friend.friendships
          end

          should "have a user that is the current user" do
            assert_equal assigns(:user), assigns(:current_user)
          end
        end
      end

      context "as an admin" do
        setup do
          @user = Factory(:admin)
          sign_in(@user)
        end

        context "and getting to his index page" do
          setup { get :index, :user_id => @user.id}

          should assign_to(:current_user)
          should assign_to(:friendships)
          should assign_to(:user)
          should respond_with(:success)
          should render_template(:index)

          should "only have the user's friendships" do
            assert_equal assigns(:friendships), @user.friendships
          end

          should "have a user that is the current user" do
            assert_equal assigns(:user), assigns(:current_user)
          end
        end

        context "and getting to his friend's index page" do
          setup { get :index, :user_id => @friend.id}

          should assign_to(:current_user)
          should assign_to(:friendships)
          should assign_to(:user)
          should respond_with(:success)
          should render_template(:index)

          should "only have the user's friendships not his friend's" do
            assert_equal assigns(:friendships), @user.friendships
            assert_not_equal assigns(:friendships), @friend.friendships
          end

          should "have a user that is the current user" do
            assert_equal assigns(:user), assigns(:current_user)
          end
        end
      end
    end
  end

  # friendships/show action
  # context "on GET to :show" do
  #   setup do
  #     @user = Factory(:active_user)
  #     @friend = Factory(:active_user)
  #     @friendship = Factory(:friendship, :user => @user, :friend => @friend)
  #     UserSession.find.destroy()
  #   end
  #
  #   context "when logged out" do
  #     setup { get :show, :id => @friendship.id }
  #
  #     should_not assign_to(:current_user)
  #     should_not assign_to(:friendship)
  #     should_not assign_to(:friend)
  #     should_not assign_to(:user)
  #     should respond_with(:redirect)
  #     should set_the_flash.to("You must be logged in to access this page")
  #     should redirect_to("the login url"){ new_user_session_url }
  #   end
  #
  #   context "when logged in as a normal user" do
  #     setup do
  #       UserSession.create(@user)
  #       get :show, :id => @friendship.id
  #     end
  #
  #     should assign_to(:current_user)
  #     should assign_to(:friendship)
  #     should assign_to(:friend)
  #     should assign_to(:user)
  #     should respond_with(:success)
  #     should render_template(:show)
  #   end
  # end

  # friendships/create action
  context "on POST to create" do
    setup do
      @user = Factory(:active_user)
      @friend = Factory(:active_user)
    end

    context "when logged out" do
      setup { post :create, :user => @user, :friend_id => @friend.id }

      should_not assign_to(:current_user)
      should_not assign_to(:user)
      should respond_with(:redirect)
      should set_the_flash.to("You must be logged in to access this page. <a href=\"/users/sign_up\">Click here to create your Buddy Account for free.</a>")
      should redirect_to("the login url"){ new_user_session_url }
    end

    context "when logged in as a normal user" do
      setup { sign_in(@user) }

      context "and creating a friend using his id" do
        setup { post :create, :user => @user, :friend_id => @friend.id }

        should assign_to(:current_user)
        should assign_to(:friendship)
        should assign_to(:user)
        should respond_with(:redirect)
        should redirect_to("root url"){ root_url }
        should set_the_flash.to("Added friend.")

        should "have a friend" do
          assert_equal 1, @user.friendships.length
          assert_equal 1, @user.friends.length
          assert_equal @user.friends.first, @friend
        end

        should "create the reciprocal friendship" do
          assert_equal 1, @friend.friendships.length
          assert_equal 1, @friend.friends.length
          assert_equal @friend.friends.first, @user
          assert_equal 2, Friendship.all.length
        end
      end

      context "and creating a friend using another user's id" do
        setup { post :create, :user => @user, :friend_id => @friend.id }

        should assign_to(:current_user)
        should assign_to(:friendship)
        should assign_to(:user)
        should respond_with(:redirect)
        should redirect_to("root url"){ root_url }
        should set_the_flash.to("Added friend.")

        should "have a friend" do
          assert_equal 1, @user.friendships.length
          assert_equal 1, @user.friends.length
          assert_equal @user.friends.first, @friend
        end

        should "create the friendship under the currently lodded in user's account not his friends" do
          assert_equal assigns(:current_user), assigns(:user)
          assert_equal assigns(:friendship).user, assigns(:current_user)
        end

        should "create the reciprocal friendship" do
          assert_equal 1, @friend.friendships.length
          assert_equal 1, @friend.friends.length
          assert_equal @friend.friends.first, @user
          assert_equal 2, Friendship.all.length
        end
      end

      context "and posting incorrect attributes" do
        setup { post :create, :user => @user, :friend_id => nil }

        should assign_to(:current_user)
        should assign_to(:friendship)
        should assign_to(:user)
        should respond_with(:redirect)
        should redirect_to("root url"){ root_url }
        should set_the_flash.to("Error occurred when adding friend.")

        should "not create a friendship" do
          assert Friendship.all.blank?
        end

        should "have errors" do
          assert assigns(:friendship).new_record?
          assert assigns(:friendship).errors[:friend_id].present?
        end
      end
    end

    context "when logged in as an admin" do
      setup do
        @user = Factory(:admin)
        sign_in(@user)
      end

      context "and creating a friend using his id" do
        setup { post :create, :user => @user, :friend_id => @friend.id }

        should assign_to(:current_user)
        should assign_to(:friendship)
        should assign_to(:user)
        should respond_with(:redirect)
        should redirect_to("root url"){ root_url }
        should set_the_flash.to("Added friend.")

        should "have a friend" do
          assert_equal 1, @user.friendships.length
          assert_equal 1, @user.friends.length
          assert_equal @user.friends.first, @friend
        end

        should "create the reciprocal friendship" do
          assert_equal 1, @friend.friendships.length
          assert_equal 1, @friend.friends.length
          assert_equal @friend.friends.first, @user
          assert_equal 2, Friendship.all.length
        end
      end

      context "and creating a friend using another user's id" do
        setup { post :create, :user => @user, :friend_id => @friend.id }

        should assign_to(:current_user)
        should assign_to(:friendship)
        should assign_to(:user)
        should respond_with(:redirect)
        should redirect_to("root url"){ root_url }
        should set_the_flash.to("Added friend.")

        should "have a friend" do
          assert_equal 1, @user.friendships.length
          assert_equal 1, @user.friends.length
          assert_equal @user.friends.first, @friend
        end

        should "create the friendship under the currently lodded in user's account not his friends" do
          assert_equal assigns(:current_user), assigns(:user)
          assert_equal assigns(:friendship).user, assigns(:current_user)
        end

        should "create the reciprocal friendship" do
          assert_equal 1, @friend.friendships.length
          assert_equal 1, @friend.friends.length
          assert_equal @friend.friends.first, @user
          assert_equal 2, Friendship.all.length
        end
      end

      context "and posting incorrect attributes" do
        setup { post :create, :user => @user, :friend_id => nil }

        should assign_to(:current_user)
        should assign_to(:friendship)
        should assign_to(:user)
        should respond_with(:redirect)
        should redirect_to("root url"){ root_url }
        should set_the_flash.to("Error occurred when adding friend.")

        should "not create a friendship" do
          assert Friendship.all.blank?
        end

        should "have errors" do
          assert assigns(:friendship).new_record?
          assert assigns(:friendship).errors[:friend_id].present?
        end
      end
    end
  end

  # friendships/destroy action
  context "on PUT to destroy" do
    setup do
      @user = Factory(:active_user)
      @friend = Factory(:active_user)
      @friendship = Factory(:friendship, :user => @user, :friend_id => @friend.id)
    end

    context "when logged out" do
      setup { put :destroy, :user => @user, :id => @friendship.id }

      should_not assign_to(:current_user)
      should_not assign_to(:friendship)
      should_not assign_to(:user)
      should respond_with(:redirect)
      should set_the_flash.to("You must be logged in to access this page. <a href=\"/users/sign_up\">Click here to create your Buddy Account for free.</a>")
      should redirect_to("the login url"){ new_user_session_url }
    end

    context "when logged in as normal user" do
      setup { sign_in(@user) }

      context "and posting correct attributes" do
        setup { put :destroy, :user => @user, :id => @friendship.id }

        should assign_to(:current_user)
        should assign_to(:friendship)
        should assign_to(:user)
        should respond_with(:redirect)
        should redirect_to("root url"){ root_url }
        should set_the_flash.to("Successfully ended friendship.")

        should "have no more friendships" do
          assert_equal 0, Friendship.all.length
          assert @user.friendships.blank?
        end
      end

      context "and posting to another user's account" do
        setup { put :destroy, :user => @friend, :id => @friendship.id }

        should assign_to(:current_user)
        should assign_to(:friendship)
        should assign_to(:user)
        should respond_with(:redirect)
        should redirect_to("root url"){ root_url }
        should set_the_flash.to("Successfully ended friendship.")

        should "have no more friendships" do
          assert_equal 0, Friendship.all.length
          assert @user.friendships.blank?
        end

        should "have a user that is the current user" do
          assert_equal assigns(:current_user), assigns(:user)
          assert_equal assigns(:friendship).user, assigns(:current_user)
        end
      end

      context "and posting incorrect attributes" do
        setup { put :destroy, :user => @user, :id => nil }

        should assign_to(:current_user)
        should_not assign_to(:friendship)
        should assign_to(:user)
        should respond_with(:redirect)
        should redirect_to("root url"){ root_url }
        should set_the_flash.to("Error ending friendship.")

        should "still have friendships" do
          assert_equal 2, Friendship.all.length
          assert @user.friendships.present?
        end
      end
    end

    context "when logged in as an admin" do
      setup do
        @user = Factory(:admin)
        @friendship = Factory(:friendship, :user => @user, :friend_id => @friend.id)
        sign_in(@user)
      end

      context "and posting correct attributes" do
        setup { put :destroy, :user => @user, :id => @friendship.id }

        should assign_to(:current_user)
        should assign_to(:friendship)
        should assign_to(:user)
        should respond_with(:redirect)
        should redirect_to("root url"){ root_url }
        should set_the_flash.to("Successfully ended friendship.")

        should "have no more friendships" do
          assert_equal 2, Friendship.all.length
          assert @user.friendships.blank?
        end
      end

      context "and posting to another user's account" do
        setup { put :destroy, :user => @friend, :id => @friendship.id }

        should assign_to(:current_user)
        should assign_to(:friendship)
        should assign_to(:user)
        should respond_with(:redirect)
        should redirect_to("root url"){ root_url }
        should set_the_flash.to("Successfully ended friendship.")

        should "have no more friendships" do
          assert_equal 2, Friendship.all.length
          assert @user.friendships.blank?
        end

        should "have a user that is the current user" do
          assert_equal assigns(:current_user), assigns(:user)
          assert_equal assigns(:friendship).user, assigns(:current_user)
        end
      end

      context "and posting incorrect attributes" do
        setup { put :destroy, :user => @user, :id => nil }

        should assign_to(:current_user)
        should_not assign_to(:friendship)
        should assign_to(:user)
        should respond_with(:redirect)
        should redirect_to("root url"){ root_url }
        should set_the_flash.to("Error ending friendship.")

        should "still have friendships" do
          assert_equal 4, Friendship.all.length
          assert @user.friendships.present?
        end
      end
    end
  end
end

