require 'test_helper'

class PaypalControllerTest < ActionController::TestCase

  # POST to CREATE
  context "on POST to CREATE" do
    setup do
      @price = Factory(:price)
      @iou = Factory(:iou, :price => @price)
      post :create, :order_id => @iou.id, :amt => "3.00", :cur => @iou.currency, :name => "Order #{@iou.id}", :description => "This is an order for a 3,00 Voucher at Bar Butter"
    end
    should respond_with(:redirect)
  end
  
  # GET to CONFIRMATION
  context "on GET to CONFIRMATION" do    
    context "with credentials for an Iou and one voucher" do
      setup do
        @price = Factory(:price, :cents => "300")
        @iou = Factory(:iou, :price => @price)
        # Put these after factories so that we dont include the emails and stuff 
        # that we created when we created the price and ious
        @email_count = ActionMailer::Base.deliveries.length
        @delayed_job_count = Delayed::Job.count
        get :confirmation, :order_id => @iou.id, :amt => "3.00", :cur => "EUR"
      end
  
      should assign_to(:iou)
      should assign_to(:status)
      should set_the_flash.to("<strong>Sweet!</strong> Paypal has confirmed your payment!")
  
      should "increase the number of emails" do
        assert_equal 1, ActionMailer::Base.deliveries.length - @email_count, ActionMailer::Base.deliveries.last(2).inspect
      end
  
      should "increase the number of delayed jobs, setting a date for expiration, and two voucher reminder emails" do
        assert_equal 3, Delayed::Job.count - @delayed_job_count, Delayed::Job.last(2).inspect
      end
      
      should "assign the same iou as passed in" do
        assert_equal @iou, assigns(:iou)
      end
    
      should "have a successful status" do
        assert assigns(:status) == "success"
      end
      
      should "have a paid iou" do
        assert assigns(:iou).paid?
      end
  
      should "have one voucher" do
        assert_equal assigns(:iou).vouchers.length, 1, "!!!!!quantity: #{assigns(:iou).quantity}"
      end
    end
    
    context "with credentials for an Iou with a quantity of 2" do
      setup do
        @price = Factory(:price, :cents => "150")
        @iou = Factory(:iou, :price => @price, :quantity => 2)
        # Put these after factories so that we dont include the emails and stuff 
        # that we created when we created the price and ious
        @email_count = ActionMailer::Base.deliveries.length
        @delayed_job_count = Delayed::Job.count
        get :confirmation, :order_id => @iou.id, :amt => "3.00", :cur => "EUR"
      end
  
      should assign_to(:iou)
      should assign_to(:status)
      should set_the_flash.to("<strong>Sweet!</strong> Paypal has confirmed your payment!")
  
      # Use this if you use fixtures
      # should "increase the number of emails (one email for customer and one to let the bar know they have a new voucher list)" do
      #   assert_equal 2, ActionMailer::Base.deliveries.length - @email_count
      # end
      
      should "increase the number of emails" do
        assert_equal 1, ActionMailer::Base.deliveries.length - @email_count, ActionMailer::Base.deliveries.last(2).inspect
      end
  
      should "increase the number of delayed jobs, setting a date for expiration, one for each iou and setting two reminder emails, one per iou" do
        assert_equal 3, Delayed::Job.count - @delayed_job_count
      end
      
      should "assign the same iou as passed in" do
        assert_equal @iou, assigns(:iou)
      end
    
      should "have a successful status" do
        assert assigns(:status) == "success"
      end
      
      should "have a paid iou" do
        assert assigns(:iou).paid?
      end
  
      should "have two vouchers" do
        assert_equal assigns(:iou).vouchers.length, 2
      end
    end
    
  end
  
end
