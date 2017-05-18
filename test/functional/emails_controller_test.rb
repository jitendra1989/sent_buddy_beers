require 'test_helper'

class EmailsControllerTest < ActionController::TestCase
  fixtures :users, :emails

  # I think this test should be a unit test but I couldn't figure out how to build it due to instance variable persistence
  context "A pending email" do
    setup do
      assert_difference 'ActionMailer::Base.deliveries.length', 1 do
        @email = Email.create(:email => "email@example.com", :user_id => users(:customer).id)
      end
    end

    should "not be able to be set to primary" do
      @email.primary = true
      @email.save
      @email = Email.find_by_email_and_user_id("email@example.com", users(:customer).id)
      assert !@email.primary
    end
  end
end
