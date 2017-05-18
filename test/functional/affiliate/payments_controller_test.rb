require 'test_helper'

class Affiliate::PaymentsControllerTest < ActionController::TestCase
  fixtures :users

  # index

  context "GET to :index" do

    setup do
      3.times do
        Factory(:payment, :amount => Money.new(200))
      end
      Factory(:payment, :amount => Money.new(300), :affiliate_id => users(:affiliate).id)
      sign_out :user
    end

    context "when logged in" do
      context "as an affiliate" do
        setup do
          sign_in :affiliate
          get :index
        end

        should assign_to(:payments)
        should assign_to(:current_user)
        should_not assign_to(:payment)
        should respond_with(:success)
        should render_template(:index)
        should_not set_the_flash

        should "have all the payments belonging to the user" do
          assert_equal users(:affiliate).payments.length, assigns(:payments).length
        end

        should "not have all the payments" do
          assert Payment.count > assigns(:payments).length
        end
      end

      context "as a customer" do
        setup do
          sign_in :customer
          get :index
        end

        should_not assign_to(:payments)
        should assign_to(:current_user)
        should_not assign_to(:payment)
        should respond_with(:redirect)
        should redirect_to("the home page"){ root_url }
        should set_the_flash.to("You do not have the correct privileges to access this page")
      end
    end

    context "when logged out" do
      setup { get :index }

      should_not assign_to(:payments)
      should_not assign_to(:current_user)
      should_not assign_to(:payment)
      should respond_with(:redirect)
      should redirect_to("the home page"){ root_url }
      should set_the_flash.to("You do not have the correct privileges to access this page")
    end
  end

  # show

  context "GET to :show" do

    setup do
      @payment = Factory(:payment, :amount => Money.new(200))
      @payment2 = Factory(:payment, :amount => Money.new(200), :affiliate_id => users(:affiliate).id)
      sign_out :user
    end

    context "when logged in" do
      context "as an affiliate" do
        context "and getting a payment that belongs to this affiliate" do
          setup do
            sign_in :affiliate
            get :show, :id => @payment2.id
          end

          should assign_to(:current_user)
          should assign_to(:payment)
          should respond_with(:success)
          should render_template(:show)
          should_not set_the_flash
        end

        context "and getting a payment that does not belongs to this affiliate" do
          setup do
            sign_in :affiliate
            get :show, :id => @payment.id
          end

          should assign_to(:current_user)
          should_not assign_to(:payment)
          should respond_with(:redirect)
          should redirect_to("the home page"){ affiliate_payments_url }
          should set_the_flash.to("You do not have the correct privileges to access this page")
        end
      end
      context "as a customer" do
        setup do
          sign_in :customer
          get :show, :id => @payment.id
        end

        should_not assign_to(:payments)
        should assign_to(:current_user)
        should_not assign_to(:payment)
        should respond_with(:redirect)
        should redirect_to("the home page"){ root_url }
        should set_the_flash.to("You do not have the correct privileges to access this page")
      end
    end

    context "when logged out" do
      setup { get :show, :id => @payment.id }

      should_not assign_to(:payments)
      should_not assign_to(:current_user)
      should_not assign_to(:payment)
      should respond_with(:redirect)
      should redirect_to("the home page"){ root_url }
      should set_the_flash.to("You do not have the correct privileges to access this page")
    end
  end

end
