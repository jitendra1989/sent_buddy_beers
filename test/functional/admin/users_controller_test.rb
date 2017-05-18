require 'test_helper'

class Admin::UsersControllerTest < ActionController::TestCase
  fixtures :users

  #index
  context "GET to :index" do
    context "while logged in as admin" do
      setup do
        sign_in :admin
        get :index
      end

      should assign_to(:users)
      should assign_to(:current_user)
      should respond_with(:success)
      should render_template(:index)
      should_not set_the_flash
      
      should "only show paginated active users" do
        assert_equal User.where("users.confirmed_at IS NOT NULL").order("created_at DESC").first(50), assigns(:users)
      end
    end
    
    context "while logged in as admin with a query" do
      setup do
        Factory(:customer, :name => "Johnny")
        sign_in :admin
        get :index, :query => "Johnny"
      end
      
      should assign_to(:users)
      should assign_to(:current_user)
      should respond_with(:success)
      should render_template(:index)
      should_not set_the_flash
      
      should "only show queried users" do
        assert_equal 1, assigns(:users).length
      end
    end

    context "while logged in as customer" do
      setup do
        sign_in :customer
        get :index
      end

      should_not assign_to(:users)
      should assign_to(:current_user)
      should respond_with(:redirect)
      should redirect_to("the home page"){ root_url }
      should set_the_flash.to("You do not have the correct privileges to access this page")
    end
  end
  
  context "GET to :show" do
    context "while logged in as admin" do
      setup do
        sign_in :admin
        get :show, :id => users(:customer).id
      end

      should assign_to(:user)
      should assign_to(:current_user)
      should respond_with(:success)
      should render_template(:show)
      should_not set_the_flash
    end
  end

  #edit
  context "GET to :edit" do
    context "while logged in as admin" do
      setup do
        sign_in :admin
        get :edit, :id => users(:customer).id
      end

      should assign_to(:user)
      should assign_to(:current_user)
      should respond_with(:success)
      should render_template(:edit)
      should_not set_the_flash
    end

    context "while logged in as customer" do
      setup do
        sign_in :customer
        get :edit, :id => users(:customer).id
      end

      should_not assign_to(:user)
      should assign_to(:current_user)
      should respond_with(:redirect)
      should redirect_to("the home page"){ root_url }
      should set_the_flash.to("You do not have the correct privileges to access this page")
    end
  end

  # update
  context "POST to :update" do
    context "while logged in as admin" do
      setup do
        sign_in :admin
      end

      context "and changing a customer to a bro" do
        setup do
          assert_difference "Bro.count" do
            post :update, :id => users(:customer).id, :user => { :type => "Bro" }
          end
        end

        should assign_to(:user)
        should assign_to(:current_user)
        should respond_with(:redirect)
        should redirect_to("the users listing page"){ admin_users_url }
        should set_the_flash.to("User updated!")
      end
    end

    context "while logged in as customer" do
      setup do
        sign_in :customer
      end

      context "and changing a customer to a bro" do
        setup do
          post :update, :id => users(:customer).id, :user => { :type => "Bro" }
        end

        should_not assign_to(:user)
        should assign_to(:current_user)
        should respond_with(:redirect)
        should redirect_to("the home page"){ root_url }
        should set_the_flash.to("You do not have the correct privileges to access this page")
      end
    end
  end
end
