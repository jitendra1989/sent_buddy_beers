require 'test_helper'

class CreditEventTest < ActiveSupport::TestCase
  should belong_to(:user)
  should belong_to(:site)
  should belong_to(:iou)
  
  context "a new credit_event" do
    setup { @credit_event = Factory.build(:credit_event) }
    context "with a user" do
      setup { @credit_event.user = Factory(:user) }
      context "and a virtual amount" do
        setup { @credit_event.virtualamount = "100" }
        context "that is saved" do
          setup { @credit_event.save }
          
          should "debit the user" do
            assert_equal -100, @credit_event.user.credits.to_i
          end
        end
      end
    end
  end
      
end
