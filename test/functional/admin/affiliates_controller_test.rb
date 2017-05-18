require 'test_helper'

class Admin::AffiliatesControllerTest < ActionController::TestCase
  fixtures :users

  # index
  context "GET to index" do
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
    end

    context "when logged in as customer" do
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

  # show

  # new
  context "GET to new" do
    context "while logged in as admin" do
      setup do
        sign_in :admin
        get :new
      end

      should assign_to(:user)
      should assign_to(:current_user)
      should respond_with(:success)
      should render_template(:new)
      should_not set_the_flash

      should "have an instance of user that is a new record" do
        assert assigns(:user).new_record?
      end
    end

    context "when logged in as customer" do
      setup do
        sign_in :customer
        get :new
      end

      should_not assign_to(:user)
      should assign_to(:current_user)
      should respond_with(:redirect)
      should redirect_to("the home page"){ root_url }
      should set_the_flash.to("You do not have the correct privileges to access this page")
    end
  end

end
