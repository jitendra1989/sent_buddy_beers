require 'test_helper'

class Admin::PaymentsControllerTest < ActionController::TestCase
  fixtures :users

  # index

  context "GET to :index" do

    setup do
      3.times do
        Factory(:payment, :amount => Money.new(200))
      end
      sign_out :user
    end

    context "when logged in" do
      context "as an admin" do
        setup do
          sign_in :admin
          get :index
        end

        should assign_to(:payments)
        should assign_to(:current_user)
        should_not assign_to(:payment)
        should respond_with(:success)
        should render_template(:index)
        should_not set_the_flash

        should "have all the payments" do
          assert_equal Payment.all.length, assigns(:payments).length
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
      sign_out :user
    end

    context "when logged in" do
      context "as an admin" do
        setup do
          sign_in :admin
          get :show, :id => @payment.id
        end

        should assign_to(:current_user)
        should assign_to(:payment)
        should respond_with(:success)
        should render_template(:show)
        should_not set_the_flash
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

  # edit

  context "GET to :edit" do

    setup do
      @payment = Factory(:payment, :amount => Money.new(200))
      sign_out :user
    end

    context "when logged in" do
      context "as an admin" do
        setup do
          sign_in :admin
          get :edit, :id => @payment.id
        end

        should assign_to(:current_user)
        should assign_to(:payment)
        should respond_with(:success)
        should render_template(:edit)
        should_not set_the_flash
      end
      context "as a customer" do
        setup do
          sign_in :customer
          get :edit, :id => @payment.id
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
      setup { get :edit, :id => @payment.id }

      should_not assign_to(:payments)
      should_not assign_to(:current_user)
      should_not assign_to(:payment)
      should respond_with(:redirect)
      should redirect_to("the home page"){ root_url }
      should set_the_flash.to("You do not have the correct privileges to access this page")
    end
  end

  # update

  context "PUT to :update" do

    setup do
      @payment = Factory(:payment, :amount => Money.new(200))
      sign_out :user
    end

    context "when logged in" do
      context "as an admin" do
        setup do
          sign_in :admin
          put :update, :id => @payment.id, :payment => {:amount => "3.00", :notes => "Some notes", :admin_notes => "admin notes", :affiliate_name => "that other guy"}
        end

        should assign_to(:current_user)
        should assign_to(:payment)
        should respond_with(:redirect)
        should redirect_to("the payment page"){ admin_payment_url(assigns(:payment)) }
        should set_the_flash.to("Payment updated!")
      end
      context "as a customer" do
        setup do
          sign_in :customer
          put :update, :id => @payment.id, :payment => {:amount => "3.00", :notes => "Some notes", :admin_notes => "admin notes", :affiliate_name => "that other guy"}
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
      setup { put :update, :id => @payment.id, :payment => {:amount => "3.00", :notes => "Some notes", :admin_notes => "admin notes", :affiliate_name => "that other guy"} }

      should_not assign_to(:payments)
      should_not assign_to(:current_user)
      should_not assign_to(:payment)
      should respond_with(:redirect)
      should redirect_to("the home page"){ root_url }
      should set_the_flash.to("You do not have the correct privileges to access this page")
    end
  end

  # destroy

  context "PUT to :destroy" do

    setup do
      @payment = Factory(:payment, :amount => Money.new(200))
      sign_out :user
    end

    context "when logged in" do
      context "as an admin" do
        setup do
          sign_in :admin
          @payment_count = Payment.count
          put :destroy, :id => @payment.id
        end

        should assign_to(:current_user)
        should assign_to(:payment)
        should respond_with(:redirect)
        should redirect_to("the payments page"){ admin_payments_url }
        should set_the_flash.to("Payment Deleted!")

        should "remove a payment" do
          assert_equal -1, Payment.count - @payment_count
        end
      end
      context "as a customer" do
        setup do
          sign_in :customer
          @payment_count = Payment.count
          put :destroy, :id => @payment.id
        end

        should_not assign_to(:payments)
        should assign_to(:current_user)
        should_not assign_to(:payment)
        should respond_with(:redirect)
        should redirect_to("the home page"){ root_url }
        should set_the_flash.to("You do not have the correct privileges to access this page")

        should "still have all the payments" do
          assert_equal 0, Payment.count - @payment_count
        end
      end
    end

    context "when logged out" do
      setup do
        @payment_count = Payment.count
        put :destroy, :id => @payment.id
      end

      should_not assign_to(:payments)
      should_not assign_to(:current_user)
      should_not assign_to(:payment)
      should respond_with(:redirect)
      should redirect_to("the home page"){ root_url }
      should set_the_flash.to("You do not have the correct privileges to access this page")

      should "still have all the payments" do
        assert_equal 0, Payment.count - @payment_count
      end
    end
  end

  # toggle

  context "POST to :toggle" do

    setup do
      @iou = Factory.create(:iou)
      @payment = Factory(:payment)
      @line_item = Factory(:line_item, :iou => @iou, :voucher => @iou.vouchers.first, :payment_id => @payment.id)
      @payment.save
      sign_out :user
    end

    context "when logged in" do
      context "as an admin" do
        setup do
          sign_in :admin
          @paid_payment_count = Payment.processed.length
          @email_count = ActionMailer::Base.deliveries.length
          post :toggle, :id => @payment.id
        end

        should assign_to(:current_user)
        should assign_to(:payment)

        should "mark the payment as paid" do
          assert Payment.find(@payment.id).paid
        end

        should "increase paid payment count" do
          assert_equal 1, Payment.processed.length - @paid_payment_count
        end

        should "send an email" do
          assert (ActionMailer::Base.deliveries.length - @email_count) == 1, assigns(:payment).inspect
        end

        context "and setting a paid invoice to unpaid" do
          setup { post :toggle, :id => @payment.id }

          should "mark the payment as unpaid" do
            assert !Payment.find(@payment.id).paid
          end

          should "decrease paid payment count" do
            assert_equal 0, Payment.processed.length - @paid_payment_count
          end
        end
      end
      context "as a customer" do
        setup do
          sign_in :customer
          @paid_payment_count = Payment.processed.length
          @email_count = ActionMailer::Base.deliveries.length
          post :toggle, :id => @payment.id
        end

        should assign_to(:current_user)
        should_not assign_to(:payment)
        should respond_with(:redirect)
        should redirect_to("the home page"){ root_url }
        should set_the_flash.to("You do not have the correct privileges to access this page")

        should "not mark the payment as paid" do
          assert !Payment.find(@payment.id).paid
        end

        should "not increase paid payment count" do
          assert_equal 0, Payment.processed.length - @paid_payment_count
        end

        should "not send an email" do
          assert_equal 0, ActionMailer::Base.deliveries.length - @email_count
        end
      end
    end

    context "when logged out" do
      setup do
        @payment_count = Payment.count
        @paid_payment_count = Payment.processed.length
        @email_count = ActionMailer::Base.deliveries.length
        post :toggle, :id => @payment.id
      end

      should_not assign_to(:current_user)
      should_not assign_to(:payment)
      should respond_with(:redirect)
      should redirect_to("the home page"){ root_url }
      should set_the_flash.to("You do not have the correct privileges to access this page")

      should "not mark the payment as paid" do
        assert !Payment.find(@payment.id).paid
      end

      should "not increase paid payment count" do
        assert_equal 0, Payment.processed.length - @paid_payment_count
      end

      should "not send an email" do
        assert_equal 0, ActionMailer::Base.deliveries.length - @email_count
      end
    end
  end

end
