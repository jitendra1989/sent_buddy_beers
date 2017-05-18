require 'test_helper'

class RegistrationsControllerTest < ActionController::TestCase
  fixtures :users

  # users/new
  context "on GET to :new" do
    context "while logged out" do
      setup { get :new }

      should assign_to(:user)
      should respond_with(:success)
      should render_template(:new)
      should_not set_the_flash

      should "have a new user record" do
        assert assigns(:user).new_record?
      end
      
      context "with sponsorpay ref" do
        setup { get :new, :ref => "sponsorpay"}
        
        should assign_to(:referrer)
        should assign_to(:registration_layout)
      end
    end

    context "while logged in as a user" do
      setup do
        sign_in(:customer)
        get :new
      end

      should respond_with(:redirect)
      should_not assign_to(:user)
      should redirect_to("the home page"){ root_url }
    end
    
    
  end

  # users/create
  context "on POST to :create" do
    context "while not logged in" do
      context "and posting all correct user attributes" do
        setup do
          post :create, :customer => Factory.attributes_for(:user, :emails_attributes => [{:email => "kennyfuckingp@example.com"}])
        end

        should assign_to(:user)
        should respond_with(:redirect)
        should set_the_flash.to("<strong>Your account has been created.</strong> Just check your e-mail for the confirmation link, and you're ready to go!")
        should redirect_to("the confirmation page"){ users_sign_up_complete_url }

        should "not be be logged in (without confirmation)" do
          assert_nil @controller.current_user
        end

        should "save the site customer signed up with" do
          assert_equal @controller.current_site, assigns(:user).sign_up_site
        end
      end

      context "and posting missing attributes" do
        setup do
          post :create, :customer => {:login => nil, :password => nil, :password_confirmation => nil, :emails_attributes => {"0" => {:email => ""}}, :name => nil}
        end

        should assign_to(:user)
        should respond_with(:success)
        should render_template(:new)
        should_not set_the_flash

        should "create an instance that is a new record and has errors" do
          assert assigns(:user).new_record?
          assert assigns(:user).errors[:login].present?
          assert assigns(:user).errors[:password].present?
          assert assigns(:user).errors[:name].blank?
        end

        should "not be logged in" do
          assert_nil @controller.current_user
        end
      end
    end

    context "while logged in as a user" do
      setup do
        assert_no_difference "User.count" do
          assert_no_difference('ActionMailer::Base.deliveries.length', 1) do
            sign_in(:customer)
            post :create, :customer => Factory.attributes_for(:user, :emails_attributes => [{:email => "kennyfuckingp@example.com"}])
          end
        end
      end

      should respond_with(:redirect)
      should_not assign_to(:user)
      should redirect_to("the new iou url"){ root_url }
    end
  end
  # users/edit

  context "on GET to :edit" do
    context "while not logged in" do
      setup { get :edit }

      should_not assign_to(:user)
      should respond_with(:redirect)
      should set_the_flash.to("You must be logged in to access this page. <a href=\"/users/sign_up\">Click here to create your Buddy Account for free.</a>")
      should redirect_to("the user login page"){ new_user_session_url }
    end

    context "while logged in" do
      context "and using an existing user's id" do
        setup do
          sign_in(:customer)
          get :edit
        end

        should assign_to(:current_user)
        should assign_to(:user)
        should respond_with(:success)
        should render_template(:edit)
        should_not set_the_flash

        should "assign the same user as the id" do
          assert_equal assigns(:user), users(:customer)
        end
      end
    end
  end

  # users/update

  context "on POST to :update" do
    context "while logged out" do
      setup { post :update, :user => Factory.attributes_for(:user, :emails_attributes => [{:email => "kennyfuckingp@example.com"}]) }

      should_not assign_to(:user)
      should respond_with(:redirect)
      should set_the_flash.to("You must be logged in to access this page. <a href=\"/users/sign_up\">Click here to create your Buddy Account for free.</a>")
      should redirect_to("the user login page"){ new_user_session_url }
    end

    context "while logged in" do
      setup do
        sign_in(:customer)
        post :update, :user => Factory.attributes_for(:user, :emails_attributes => [{:email => "kennyfuckingp@example.com"}])
      end

      should assign_to(:user)
      should respond_with(:redirect)
      should set_the_flash.to("Account updated!")
      should redirect_to("the user edit page"){ edit_user_registration_url }

      should "assign the same user as the id" do
        assert_equal assigns(:user), users(:customer)
      end
    end
  end
  
  # registrations/complete
  context "on GET to complete" do
    context "while logged out" do
      setup { get :complete }

      should_not assign_to(:user)
      should respond_with(:success)
      should render_template(:complete)
      should_not set_the_flash
    end

    context "while logged in as a user" do
      setup do
        sign_in(:customer)
        get :complete
      end

      should_not assign_to(:user)
      should respond_with(:success)
      should render_template(:complete)
      should_not set_the_flash
    end
  end
  
end
