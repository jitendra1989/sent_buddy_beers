require 'test_helper'

class Affiliate::DashboardControllerTest < ActionController::TestCase
  fixtures :users

  # index
  context "GET to index" do
    context "while logged in as affiliate" do
      setup do
        sign_in(:affiliate)
        get :index
      end

      should assign_to(:current_user)
      should assign_to(:bars)
      should assign_to(:outstanding_ious)
      should respond_with(:success)
      should render_template(:dashboard)
      should_not set_the_flash

      should "have a user that responds true to affiliate?" do
        assert assigns(:current_user).affiliate?
      end

      should "have a user that responds false to bro?" do
        assert !assigns(:current_user).bro?
      end
    end

    context "while logged in as bro" do
      setup do
        sign_in(:bro)
        get :index
      end

      should assign_to(:current_user)
      should assign_to(:bars)
      should assign_to(:outstanding_ious)
      should respond_with(:success)
      should render_template(:dashboard)
      should_not set_the_flash

      should "have a user that responds true to bro?" do
        assert assigns(:current_user).bro?
      end

      should "have a user that responds false to affiliate?" do
        assert !assigns(:current_user).affiliate?
      end
    end

    context "while logged in as customer" do
      setup do
        sign_in :customer
        get :index
      end

      should_not assign_to(:bars)
      should_not assign_to(:outstanding_ious)
      should assign_to(:current_user)
      should respond_with(:redirect)
      should redirect_to("the home page"){ root_url }
      should set_the_flash.to("You do not have the correct privileges to access this page")
    end
  end
end
