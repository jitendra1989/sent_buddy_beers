require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  fixtures :users, :emails

  # sessions/new

  context "GET to new" do
    context "when logged out" do
       setup { get :new }

       should_not assign_to(:current_user)
       should respond_with(:success)
       should render_template(:new)
       should_not set_the_flash
    end

    context "when logged in" do
      setup do
        sign_in(:customer)
        get :new
      end

      should_not assign_to(:current_user)
      should respond_with(:redirect)
      should redirect_to("the new iou url"){ new_iou_url }
    end
  end

  # sessions/create
  context "POST to create" do
    context "when logged out" do
      context "and logging in as customer" do
        setup { post :create, :user => {:username => users(:customer).login, :password => "foobar"} }

        should respond_with(:redirect)
        should set_the_flash.to("Login successful!")
        should redirect_to("the new iou page") { new_iou_url }

        should "make the current user the user who logged in" do
          assert_equal assigns(:current_user), users(:customer)
        end
      end
      
      context "and logging in as customer using email address" do
        setup { post :create, :user => {:username => users(:customer).email, :password => "foobar"} }

        should respond_with(:redirect)
        should set_the_flash.to("Login successful!")
        should redirect_to("the new iou page") { new_iou_url }

        should "make the current user the user who logged in" do
          assert_equal assigns(:current_user), users(:customer), users(:customer).emails
        end
      end
      
      context "and logging in as customer using a mixed case login" do
        setup { post :create, :user => {:username => users(:customer).login.camelcase, :password => "foobar"} }

        should respond_with(:redirect)
        should set_the_flash.to("Login successful!")
        should redirect_to("the new iou page") { new_iou_url }

        should "make the current user the user who logged in" do
          assert_equal assigns(:current_user), users(:customer), users(:customer).emails
        end
      end

      context "and logging in as affiliate" do
        setup { post :create, :user => {:username => users(:affiliate).login, :password => "foobar"} }

        should respond_with(:redirect)
        should set_the_flash.to("Login successful!")
        # should redirect_to("the affiliate backend"){ affiliate_root_url }
        should redirect_to("the new iou page") { new_iou_url }

        should "make the current user the user who logged in and an affiliate" do
          assert_equal assigns(:current_user), users(:affiliate)
          assert assigns(:current_user).affiliate?
        end
      end

      context "and logging in as bro" do
        setup { post :create, :user => {:username => users(:bro).login, :password => "foobar"} }

        should respond_with(:redirect)
        should set_the_flash.to("Login successful!")
        # should redirect_to("the affiliate backend"){ affiliate_root_url }
        should redirect_to("the new iou page") { new_iou_url }

        should "make the current user the user who logged in and a bro" do
          assert_equal assigns(:current_user), users(:bro)
          assert assigns(:current_user).bro?
        end
      end

      context "and logging in as admin" do
        setup { post :create, :user => {:username => users(:admin).login, :password => "foobar"} }

        should respond_with(:redirect)
        should set_the_flash.to("Login successful!")
        # should redirect_to("the admin backend"){ admin_root_url }
        should redirect_to("the new iou page") { new_iou_url }

        should "make the current user the user who logged in and an admin" do
          assert_not_nil assigns(:current_user)
          assert @controller.current_user.admin?
        end
      end

      context "and logging in as site admin" do
        setup do
          user = Factory(:site_admin)
          post :create, :user => {:username => user.login, :password => "foobar"}
        end

        should respond_with(:redirect)
        should set_the_flash.to("Login successful!")
        # should redirect_to("the site admin backend"){ site_admin_root_url }
        should redirect_to("the new iou page") { new_iou_url }

        should "make the current user the user who logged in and a site admin" do
          assert_not_nil assigns(:current_user)
          assert @controller.current_user.site_admin?
        end
      end

      context "and posting incorrect parameters" do
        setup { post :create, :user => {:username => "notausername", :password => "notapassword"} }

        should respond_with(:success)
        should render_template(:new)
        should set_the_flash.to('Invalid login or password.')
        # should set_the_flash.to('Invalid login or password.').now
      end
    end

    context "when logged in" do
      setup do
        sign_in(:customer)
        post :create, :user => {:username => users(:customer).login, :password => "foobar" }
      end

      should_not assign_to(:current_user)
      should respond_with(:redirect)
      should redirect_to("the new iou url"){ new_iou_url }
    end
  end

  # sessions/destroy
  context "POST to destroy" do
    context "when logged in" do
      setup do
        sign_in(:customer)
        delete :destroy
      end

      should set_the_flash.to("Logout successful!")
      should redirect_to("the login url"){ new_user_session_url }
    end

    context "when logged in as a facebook user" do
      setup do
        sign_in(:facebook_user)
        delete :destroy
      end

      should set_the_flash.to("Logout successful!")
      should redirect_to("the login url"){ new_user_session_url }
    end

    context "when logged out" do
      setup do
        delete :destroy
      end

      should_not assign_to(:current_user)
      should respond_with(:redirect)
      should redirect_to("the logged in"){ new_user_session_url }
    end
  end
end
