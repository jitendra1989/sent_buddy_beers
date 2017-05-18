require 'test_helper'

class EmailInvitationsControllerTest < ActionController::TestCase
  
  context "on POST to CREATE" do
    setup do 
      @email_count = ActionMailer::Base.deliveries.length
      post :create, :email_invitation => Factory.attributes_for(:email_invitation) 
    end
    
    should assign_to(:email_invitation)
    
    should "save email" do
      assert assigns(:email_invitation).persisted?
    end
    
    should "send email" do
      assert_equal 1, ActionMailer::Base.deliveries.length - @email_count
    end
  end

end
