require 'test_helper'

class Affiliate::IousControllerTest < ActionController::TestCase
  fixtures :users, :bars

  # index
  context "GET to :index" do
    context "while logged in as affiliate" do
      setup do
        @affiliate = Factory.create(:affiliate)
        @bar = Factory.create(:bar, :affiliate => @affiliate)
        @iou = Factory.create(:iou, :quantity => 2, :price => Factory.create(:price, :bar => @bar), :bar => @bar)
        @iou.paid!
        sign_in @affiliate
        get :index, :bar_id => @bar.id 
      end

      should assign_to(:bar)
      should assign_to(:current_user)
      should assign_to(:vouchers)
      should respond_with(:success)
      should render_template(:index)
      should_not set_the_flash
    end
  end
  
  # new
  
  context "get to :new" do
    context "when logged in as affiliate" do
      setup do
        @affiliate = Factory.create(:affiliate)
        @bar = Factory.create(:bar, :affiliate => @affiliate)
        sign_in(@affiliate)
        get :new, :bar_id => @bar.id
      end

      should assign_to(:iou)
      should assign_to(:current_user)
      should respond_with(:success)
      should render_template(:new)

      should_not set_the_flash

      should "have a new iou" do
        assert assigns(:iou).new_record?
      end
    end

    context "when logged in as customer" do
      setup do
        @customer = Factory.create(:customer)
        @bar = Factory.create(:bar)
        sign_in(@customer)
        get :new, :bar_id => @bar.id
      end

      should_not assign_to(:iou)
      should assign_to(:current_user)
      should respond_with(:redirect)
      should redirect_to("the home page"){ root_url }
      should set_the_flash.to("You do not have the correct privileges to access this page")
    end
  end

  # create

  context "POST to :create" do
    context "when logged in as afilliate" do

      #Vouchers
      context "and sending a voucher to a new user" do
        setup do
          @affiliate = Factory.create(:affiliate)
          @bar = Factory.create(:bar, :affiliate => @affiliate)
          @price = Factory.create(:price, :bar => @bar)
          sign_in(@affiliate)
          @email_count = ActionMailer::Base.deliveries.length
          @iou_count = Iou.count
          post :create, :iou => Factory.attributes_for(:iou, :price => @price, :beverage => Factory.create(:beverage)), :bar_id => @bar.id
        end

        should assign_to(:iou)
        should assign_to(:current_user)
        should respond_with(:redirect)
        should redirect_to("the affiliate bar page page"){ affiliate_bar_url(@bar) }
        should set_the_flash.to("Voucher sent successfully!")

        should "increase the number of sent emails" do
          assert_equal 1, ActionMailer::Base.deliveries.length - @email_count
        end

        should "increase the number of ious" do
          assert_equal 1, Iou.count - @iou_count
        end

        context "returns an iou instance that" do
          should "have a sender and no recipient" do
            assert_not_nil assigns(:iou).sender
            assert_nil assigns(:iou).recipient
          end

          should "have an email" do
            assert_not_nil assigns(:iou).recipient_email
          end

          should "be promotional" do
            assert assigns(:iou).promotional
          end
          
          should "not be company promotional" do
            assert !assigns(:iou).company_promotional
          end

          should "be sent from the current user" do
            assert_equal assigns(:iou).sender, assigns(:current_user)
          end

          should "be paid" do
            assert assigns(:iou).paid?
          end

          should "be valid" do
            assert_equal assigns(:iou).status, "valid"
          end

          should "have a voucher" do
            assert assigns(:iou).vouchers.reload.present?, "!!! new record: #{assigns(:iou).new_record?}, valid: #{assigns(:iou).valid?}, inspection: #{assigns(:iou).errors.full_messages} !!!"
          end
        end
      end
    end

    context "when logged in as customer" do
      setup do
        @customer = Factory.create(:customer)
        @bar = Factory.create(:bar)
        sign_in(@customer)
        post :create, :iou => Factory.attributes_for(:iou, :price => Factory.create(:price, :bar => @bar)), :bar_id => @bar.id
      end

      should_not assign_to(:iou)
      should assign_to(:current_user)
      should respond_with(:redirect)
      should redirect_to("the home page"){ root_url }
      should set_the_flash.to("You do not have the correct privileges to access this page")
    end
  end

end
