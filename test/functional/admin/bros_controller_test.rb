require 'test_helper'

class Admin::BrosControllerTest < ActionController::TestCase
  fixtures :users

  # INDEX
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

end
