require 'test_helper'

class Admin::MetricsControllerTest < ActionController::TestCase
  fixtures :users
  
  context "GET to index" do
    context "while logged in as admin" do
      setup do
        sign_in :admin
        get :index
      end
      
      should assign_to(:metrics)
    end
  end
end