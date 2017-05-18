require 'test_helper'

class Api::OrdersControllerTest < ActionController::TestCase

  context "POST to :create" do
    
    setup do
      @user = Factory(:user)
      @user.confirm!
      @user.credit!(20000)
      @price = Factory(:price, :bar => Factory(:bar), :cents => 200)
      sign_in(@user)
      @order = {:recipient_name => "Kevin",
                :price_id => @price.id,
                :bar_id => @price.bar.id,
                :recipient_email => "travis@buddydrinks.com",
                :recipient_name => "travis",
                :sender_name => "Mimi", 
                :memo => "This is the shit",
                :quantity => 1 }
    end
    
    context "with correct params and paying with buddybucks" do
      setup do
        @credit_events_count = CreditEvent.all.size
        post :create, :auth_token => @user.authentication_token, :order => @order, :payment_method => "buddybucks"
      end
      
      should assign_to(:order)
      should assign_to(:json)
      should respond_with(:success)
      should respond_with_content_type('application/json')
      should_not render_with_layout('application')
      should render_with_layout('email')
    
      should "have presisted" do
        assert assigns(:order).persisted?
      end
      
      should "be paid" do
        assert assigns(:order).paid?
      end
      
      should "debit the user" do
        assert_equal "19800", @user.reload.credits
      end
      
      should "create a credit event" do
        assert_equal 1, CreditEvent.all.size - @credit_events_count
      end
      
      should "render the correct json" do
        assert_response_contains("\"success\":true")
        assert_response_contains("order")
        assert_response_contains("user")
      end
    end
    
    context "with incorrect params" do
      setup do
        @credit_events_count = CreditEvent.all.size
        post :create, :auth_token => @user.authentication_token, :order => @order.merge(:price_id => nil)
      end
      
      should assign_to(:order)
      should assign_to(:json)
      should respond_with(:success)
      should respond_with_content_type('application/json')
      should_not render_with_layout
    
      should "have new_record?" do
        assert assigns(:order).new_record?
      end
      
      should "not be paid" do
        assert !assigns(:order).paid?
      end
      
      should "not debit the user" do
        assert_equal "20000", @user.reload.credits
      end
      
      should "not create a credit event" do
        assert_equal 0, CreditEvent.all.size - @credit_events_count
      end
      
      should "have an error on price_id" do
        assert assigns(:order).errors[:price_id].present?
      end
      
      should "render the correct json" do
        assert_response_contains("\"success\":false")
        assert_response_contains("errors")
      end
    end
     
    context "with correct params and paying with paypal" do
      setup do
        @credit_events_count = CreditEvent.all.size
        post :create, :auth_token => @user.authentication_token, :order => @order
      end
      
      should assign_to(:order)
      should assign_to(:json)
      should respond_with(:success)
      should respond_with_content_type('application/json')
      should_not render_with_layout
    
      should "have presisted" do
        assert assigns(:order).persisted?
      end
      
      should "not be paid" do
        assert !assigns(:order).paid?
      end
      
      should "not debit the user" do
        assert_equal "20000", @user.reload.credits
      end
      
      should "not create a credit event" do
        assert_equal 0, CreditEvent.all.size - @credit_events_count
      end
      
      should "render the correct json" do
        assert_response_contains("\"success\":true")
        assert_response_contains("order")
        assert_response_contains("\"paid\":false")
      end
    end   
  end

end
