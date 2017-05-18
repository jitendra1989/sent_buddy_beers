require 'test_helper'

class Admin::DashboardControllerTest < ActionController::TestCase

  fixtures :users

  # index
  context "GET to index" do
    context "while logged in as admin" do
      setup do
        sign_in :admin
        get :index
      end

      should assign_to(:current_user)
      should assign_to(:vouchers_sold)
      should assign_to(:vouchers_redeemed)
      should assign_to(:vouchers_open)
      should assign_to(:vouchers_expired)
      should assign_to(:vouchers_promotional)
      should respond_with(:success)
      should render_template(:dashboard)
      should render_with_layout(:admin)
      should_not set_the_flash
    end

    context "when logged in as customer" do
      setup do
        sign_in :customer
        get :index
      end

      should_not assign_to(:vouchers_sold)
      should_not assign_to(:vouchers_redeemed)
      should_not assign_to(:vouchers_open)
      should_not assign_to(:vouchers_expired)
      should_not assign_to(:vouchers_promotional)
      should assign_to(:current_user)
      should respond_with(:redirect)
      should redirect_to("the home page"){ root_url }
      should set_the_flash.to("You do not have the correct privileges to access this page")
    end
  end
end
