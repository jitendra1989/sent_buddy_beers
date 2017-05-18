require 'test_helper'

class IousControllerTest < ActionController::TestCase
  fixtures :all
  
  #Show
  context "GET to :show" do
  
    setup do 
      @iou = Factory(:iou, :recipient => Factory(:customer))
      @iou.paid!
    end
  
    # Valid, everything kosher iou
  
    context "with id and token" do
      setup { get :show, :id => @iou.id, :code => @iou.token }
  
      should assign_to(:iou)
      should_not assign_to(:current_user)
      should respond_with(:success)
      should render_template(:show)
      should_not set_the_flash
    end
    
    context "with just token" do
      setup { get :show, :code => @iou.token }
  
      should assign_to(:iou)
      should_not assign_to(:current_user)
      should respond_with(:success)
      should render_template(:show)
      should_not set_the_flash
    end
  
    # No token but logged in as the owner
  
    context "No token but logged in as the owner" do
      setup do
        sign_in(@iou.recipient)
        get :show, :id => @iou.id
      end
  
      should assign_to(:iou)
      should assign_to(:current_user)
      should respond_with(:success)
      should render_template(:show)
      should_not set_the_flash
  
      should "make sure the voucher recipient is the current user" do
        assert_equal assigns(:current_user), assigns(:iou).recipient
      end
    end
  
    # No token but logged in as the admin
  
    context "No token but logged in as the admin" do
      setup do
        sign_in(:admin)
        get :show, :id => @iou.id
      end
  
      should assign_to(:iou)
      should assign_to(:current_user)
      should respond_with(:success)
      should render_template(:show)
      should_not set_the_flash
  
      should "make sure the voucher recipient is not the current user" do
        assert_not_equal assigns(:current_user), assigns(:iou).recipient
      end
    end
  
    # No token and not logged in, should redirect
  
    context "No token and not logged in" do
      setup { get :show, :id => @iou.id }
  
      should assign_to(:iou)
      should_not assign_to(:current_user)
      should set_the_flash.to("You must be logged in to access this page. <a href=\"/users/sign_up\">Click here to create your Buddy Account for free.</a>")
      should redirect_to("the root page"){ new_user_session_url }
    end
  
    # Incorrect Token, should redirect
  
    context "Incorrect Token" do
      setup { get :show, :id => @iou.id, :token => "incorrect" }
  
      should assign_to(:iou)
      should_not assign_to(:current_user)
      should set_the_flash.to("You must be logged in to access this page. <a href=\"/users/sign_up\">Click here to create your Buddy Account for free.</a>")
      should redirect_to("the root page"){ new_user_session_url }
    end
  end

  # NEW
  context "GET to :new" do
    context "when logged in" do
      setup { sign_in(:customer) }
      context "and passing no params" do

        setup { get :new }

        should assign_to(:current_user)
        should assign_to(:iou)
        should "have a new iou instance" do
          assert assigns(:iou).new_record?
        end

        should_not assign_to(:price)
        should respond_with(:success)
        should render_template(:new)
        should_not set_the_flash
      end

      context "and passing a price_id" do
        setup { get :new, :price_id => prices(:one).id }

        should assign_to(:price)
        should assign_to(:bar)
      end
      
      context "and passing a bar_id" do
        setup { get :new, :bar_id => Factory.create(:bar).id }
        
        should assign_to(:bar)
      end
      
      context "and passing a user_id" do
        setup { get :new, :user_id => users(:customer).id }

        should assign_to(:recipient)
        
        should "give iou a recipient_id" do
          assert assigns(:iou).recipient_id
        end
        should "give iou a recipient_name" do
          assert assigns(:iou).recipient_name
        end
        should "give iou a recipient_email" do
          assert assigns(:iou).recipient_email
        end
      end
    end

    context "when NOT logged in" do
      setup do
        get :new
      end

      should_not assign_to(:current_user)
      should_not assign_to(:iou)
      should_not assign_to(:recipient)
      should_not assign_to(:sender)
      should_not assign_to(:price)
      should respond_with(:redirect)
      should redirect_to("the login page"){ new_user_session_url }
      should set_the_flash.to("You must be logged in to access this page. <a href=\"/users/sign_up\">Click here to create your Buddy Account for free.</a>")
    end
  end
  
  # CREATE
  context "POST to :create to create a new Iou" do
    setup { sign_in(:customer) }

    context "at an active bar" do
      setup do
        price = Factory(:price)
        @iou_count = Iou.count
        @delayed_job_count = Delayed::Job.count
        post :create, :iou => Factory.attributes_for(:iou, :price => price)
      end

      should assign_to(:iou)
      should assign_to(:price)
      should set_the_flash.to("<strong>Awesome.</strong> Pay for the beer below and your friend will think you're the absolute coolest!")

      should "increase the number of ious" do
        assert_equal 1, Iou.count - @iou_count
      end

      should "not increase the number of delayed jobs" do
        assert_equal 0, Delayed::Job.count - @delayed_job_count
      end

      should "have no errors" do
        assert assigns(:iou).errors.blank?, "#{assigns(:iou).errors.full_messages.to_sentence}"
      end

      should "associate iou with current site" do
        assert_equal @controller.current_site, assigns(:iou).site
      end
    end
    
    context "with an error" do
      setup do
        price = Factory(:price)
        post :create, :iou => Factory.attributes_for(:iou, :price => price, :recipient_email => "", :recipient_phone => "")
      end

      should assign_to(:iou)
      should assign_to(:price)
      should assign_to(:bar)
      should set_the_flash.to("Oops! Looks like something bogus happened.<br />Your friend's email can't be blank<br />Your friend's phone number can't be blank")
    end
  end
  
  # COMPLETED
  context "GET to :completed" do
    setup { sign_in(:customer) }
    context "for a paid voucher" do
      setup do
        price = Factory(:price)
        @iou = Factory(:iou, :price => price)
        @iou.paid!
        get :completed, :id => @iou.id
      end
    
      should assign_to(:iou)
      should_respond_with(:success)
      should_not set_the_flash
      should render_template(:pay)
    end
    context "for an unpaid voucher" do
      setup do
        get :completed, :id => Factory(:iou).id
      end
      
      should assign_to(:iou)
      should assign_to(:current_user)
      should respond_with(:redirect)
      should redirect_to("the pay iou page"){ pay_iou_url(@iou) }
      should set_the_flash.to("Sorry, bro. No free beers today; You gotta pay for your tab first.")
    end
  end
  
  # PAY
  context "GET to :pay" do
    setup { sign_in(:customer) }
    context "for a pending payment voucher" do
      setup { get :pay, :id => ious(:pending_payment_voucher).id }
      should assign_to(:user) #not sure about this. came back in merge
      should assign_to(:price) #not sure about this. came back in merge
      should respond_with(:success)
      should render_template(:pay)
      should assign_to(:current_user)

      should "have a user that is equal to the current user" do
        assert_equal assigns(:user), assigns(:current_user)
      end
    end
    context "for a paid voucher" do
      setup do
        @iou = Factory(:iou)
        @iou.paid!
        get :pay, :id => @iou.id
      end
      
      should assign_to(:current_user)
      should respond_with(:redirect)
      should redirect_to("the completed iou page"){ completed_iou_url(@iou) }
      should_not set_the_flash
    end
  end
  
  #CONFIRM
  context "GET to :confirm" do
    setup do
      @user = Factory(:customer)
      sign_in(@user)
      @iou = Factory(:iou, :price => Factory(:price, :cents => 300), :sender => @user)
      get :confirm, :id => @iou.id
    end
    
    should respond_with(:success)
    should render_template(:confirm)
    should render_with_layout(:buddybucks)
    should assign_to(:current_user)
    should assign_to(:user)
    should assign_to(:iou)
    should_not set_the_flash
    
    context "with assigned credit_event" do
      should assign_to(:credit_event)
      
      should "be a new record" do
        assert assigns(:credit_event).new_record?
      end
    
      should "have the same iou" do
        assert_equal assigns(:iou), @iou
      end
      
      should "have the correct price" do
        assert_equal assigns(:credit_event).virtualamount.to_i, 300
      end
    end
    
  end

end
