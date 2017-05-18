require 'test_helper'

class Admin::IousControllerTest < ActionController::TestCase
  fixtures :users, :ious, :emails

  context "get to :new" do
    context "when logged in as admin" do
      setup do
        sign_in :admin
        get :new
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
        sign_in :customer
        get :new
      end

      should_not assign_to(:iou)
      should assign_to(:current_user)
      should respond_with(:redirect)
      should redirect_to("the home page"){ root_url }
      should set_the_flash.to("You do not have the correct privileges to access this page")
    end
  end

  context "POST to :create" do
    context "when logged in as admin" do

      #Vouchers

      context "and sending a voucher to an existing user" do
        setup do
          sign_in :admin
          @email_count = ActionMailer::Base.deliveries.length
          @iou_count = Iou.count
          post :create, :iou => Factory.attributes_for(:iou, :price => Factory(:price), :recipient_email => nil, :recipient_id => users(:customer).id, :site => Site.default)
        end

        should assign_to(:iou)
        should assign_to(:current_user)
        should respond_with(:redirect)
        should redirect_to("the admin home page"){ admin_root_url }
        should set_the_flash.to("Voucher sent successfully!")

        should "increase the number of sent emails" do
          assert_equal 1, ActionMailer::Base.deliveries.length - @email_count
        end

        should "increase the number of ious" do
          assert_equal 1, Iou.count - @iou_count
        end

        context "returns an iou instance that" do
          should "have a sender and recipient" do
            assert_not_nil assigns(:iou).sender
            assert_not_nil assigns(:iou).recipient
          end

          should "have an expiration date" do
            assert_not_nil assigns(:iou).expires_at, "expires: #{assigns(:iou).expires_at}"
          end

          should "have an email" do
            assert_not_nil assigns(:iou).recipient_email
          end

          should "not be promotional" do
            assert !assigns(:iou).promotional
          end

          should "be company promotional" do
            assert assigns(:iou).company_promotional
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
            assert assigns(:iou).vouchers.present?
          end
        end
      end

      context "and sending a voucher to a new user" do
        setup do
          sign_in :admin
          @email_count = ActionMailer::Base.deliveries.length
          @iou_count = Iou.count
          post :create, :iou => Factory.attributes_for(:iou, :price => Factory(:price), :site => Site.default)
        end

        should assign_to(:iou)
        should assign_to(:current_user)
        should respond_with(:redirect)
        should redirect_to("the admin home page"){ admin_root_url }
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

          should "not be promotional" do
            assert !assigns(:iou).promotional
          end

          should "be company promotional" do
            assert assigns(:iou).company_promotional
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
            assert assigns(:iou).vouchers.present?
          end
        end
      end
    end

    context "when logged in as customer" do
      setup do
        sign_in :customer
        post :create, :iou => Factory.attributes_for(:iou, :price => Factory(:price))
      end

      should_not assign_to(:iou)
      should assign_to(:current_user)
      should respond_with(:redirect)
      should redirect_to("the home page"){ root_url }
      should set_the_flash.to("You do not have the correct privileges to access this page")
    end
  end

end
