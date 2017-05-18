require 'test_helper'

class ConfirmationsControllerTest < ActionController::TestCase
  fixtures :users, :emails

  # confirmations/show

  context "GET to show" do
    context "when logged out" do
      context "and activating a user" do
        setup do
          get :show, :confirmation_token => users(:unactivated_customer).confirmation_token
        end

        should assign_to(:user)
        should respond_with(:redirect)
        should redirect_to("the new iou page"){ new_iou_url }
        should set_the_flash.to({:notice => "Sweet! You've activated your account. Start being awesome and sending some beers!"})

        should "now be an active user" do
          assert assigns(:user).active_for_authentication?
        end

        should "have a primary email" do
          assert !assigns(:user).emails.primary.blank?
        end
      end

      context "and activating a non-present user" do
        setup do
          get :show, :confirmation_token => "notanactivationcode"
        end

        should respond_with(:redirect)
        should redirect_to("the new user registration page"){ new_user_registration_url }
        should set_the_flash.to("Oh no! There was an error confirming your account: Confirmation token is invalid")
      end

      context "and trying to activate an activated user" do
        setup do
          get :show, :confirmation_token => users(:unactivated_customer).confirmation_token
        end

        should assign_to(:user)
        should respond_with(:redirect)
        should redirect_to("the new iou page"){ new_iou_url }
        should set_the_flash.to({:notice => "Sweet! You've activated your account. Start being awesome and sending some beers!"})

        should "have user active user" do
          assert assigns(:user).active_for_authentication?
        end
      end
    end
  end
end
