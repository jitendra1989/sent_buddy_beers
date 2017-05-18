require 'test_helper'

class EmploymentTest < ActiveSupport::TestCase
  
  setup { Factory(:employment) }
  
  should belong_to(:user)
   should belong_to(:bar)
   
   should validate_presence_of(:user)
   should validate_presence_of(:bar)
   
   should validate_uniqueness_of(:user_id).scoped_to(:bar_id).with_message(/is already employed by this bar/)
  
  context "a new employment" do
    setup do
      @user = Factory(:user)
      @bar = Factory(:bar)
      @email_size = ActionMailer::Base.deliveries.size
      @employment = Factory(:employment, :user => @user, :bar => @bar)
      @email = ActionMailer::Base.deliveries.last
    end
    
    should "send an email" do
       assert_not_nil @email, ActionMailer::Base.deliveries.inspect
       assert_equal 1, ActionMailer::Base.deliveries.size - @email_size
    end
    
    should "have the correct subject" do
       assert @email.subject.include?("You're now an employee of")
       assert @email.subject.include?("on Buddy Beers!")
    end
    
    should "have the correct to address" do
       assert @email.to[0], "expected but was: #{@email.to[0]}" #.include?("example.com")
    end
    
    should "have the correct from address" do
        assert_equal @email.from[0], 'noreply@buddydrinks.com'
     end
     
     should "be inactive" do
       assert !@employment.active?
     end
  end
  
end
