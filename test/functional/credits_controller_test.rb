require 'test_helper'

class CreditsControllerTest < ActionController::TestCase
  fixtures :sites, :ious, :users, :bars, :vouchers, :cities, :countries

  # index
  context "on GET to index" do
    setup do
      sign_in(:customer)
      get :index, :user_id => users(:customer).id
    end

    should respond_with(:success)
    should render_template(:index)
    should assign_to(:user)
    should assign_to(:transaction_token)
    should assign_to(:amounts)
    
    context "amounts array" do
      should "contain hashes" do
        assert assigns(:amounts).first.is_a?(Hash)
      end
    end
  end

  # success - what the ultimate pay redirects to after successful purchase
  context "on GET to success" do
    setup do
      sign_in(:customer)
      @credit_event_count = CreditEvent.count
      get :success, :user_id => users(:customer).id, :id => String.tokenize, :token => "B4G7oLcLInsSo4E18XdPlmPCe9TVg9noOPWEH3yoeND", "noLb" => "1"
    end

    should assign_to(:user)
    should assign_to(:credit_event)
    should redirect_to("the user's credits page"){ user_credits_url(assigns(:user)) } 
    should set_the_flash.to("<strong>Your purchase was successful!</strong> As soon as our payment provider notifies us it will be reflected in your balance. This could be instantaneous so if your balance hasn't changed wait a couple seconds and reload the page.")
    
    context "credit event" do
      should "not be a new record" do
        assert !assigns(:credit_event).new_record?
      end
      
      should "increase the number of credit events" do
        assert_equal 1, @credit_event_count = CreditEvent.count
      end
      
      should "mark noLb as true" do
        assert assigns(:credit_event).no_lib
      end 
    end
  end

  # postback - what ultimate pay posts to in order to tell us the status of a transaction
  context "on POST to postback" do
    setup do
      @token = String.tokenize
      @user = Factory(:customer)
      @emails = ActionMailer::Base.deliveries
      @email_size = @emails.size
      @hash = Digest::MD5.hexdigest([ultimate_pay_postback[:dtdatetime], ultimate_pay_postback[:login], 
                                    "yxZMXJfoRRN1pWRa", "P9aHbg8HSjPdqbbeSCrKk3Usf7p0xj", 
                                    @user.id, ultimate_pay_postback[:commtype], 
                                    ultimate_pay_postback[:set_amount], ultimate_pay_postback[:amount], 
                                    ultimate_pay_postback[:sepamount], ultimate_pay_postback[:currency], 
                                    ultimate_pay_postback[:sn], ultimate_pay_postback[:mirror], 
                                    ultimate_pay_postback[:pbctrans], ultimate_pay_postback[:developerid], 
                                    ultimate_pay_postback[:appid], ultimate_pay_postback[:virtualamount], 
                                    ultimate_pay_postback[:virtualcurrency]].join())
      @credit_event = Factory(:credit_event, :token => @token, :user_id => @user.id)
    end

    context "passing the correct parameters" do
      context "and buying currency" do
        setup do
          @credit_event_count = CreditEvent.count
          post :postback, ultimate_pay_postback(:merchtrans => "credit-#{@token}", :userid => @user.id, :hash => @hash)
        end

        should respond_with(:success)
        should respond_with_content_type('text/html')
        
        should "render the correct text" do
          assert_response_contains("[OK]|")
          assert_response_contains("#{DateTime.now.strftime("%Y%m%d%H%M")}") #without the seconds
          assert_response_contains("|#{assigns(:credit_event).pbctrans}|[N/A]")
        end

        context "returns a credit_event that" do
          
          should assign_to(:credit_event) 
          
          should "not be nil? or a new_record" do
            assert_not_nil assigns(:credit_event)
            assert !assigns(:credit_event).new_record?
          end
        
          should "store the ultimate pay attributes" do
            assert assigns(:credit_event).site.present?
            assert assigns(:credit_event).commtype.present?
            assert assigns(:credit_event).currency.present?
            assert assigns(:credit_event).detail.present?
            assert assigns(:credit_event).timestamp.present?
            assert assigns(:credit_event).gwtid.present?
            assert assigns(:credit_event).livemode.present?
            assert assigns(:credit_event).login.present?
            assert assigns(:credit_event).mirror.present?
            assert assigns(:credit_event).payment_id.present?
            assert assigns(:credit_event).pbctrans.present?
            assert assigns(:credit_event).rescode.present?
            assert assigns(:credit_event).sepamount.present?
            assert assigns(:credit_event).set_amount.present?
            assert assigns(:credit_event).sn.present?
            assert assigns(:credit_event).virtualamount.present?
            assert assigns(:credit_event).amount.present?
          end
          
          should "have an OK status message" do
            assert_equal "[OK]", assigns(:credit_event).status_message
          end
        end
        
        context "returns a hash that" do
          
          should assign_to(:hash) 
          
          should "match the passed in hash" do
            assert_equal @hash, assigns(:hash)
          end
        
        end
        
        should "update the user's credits" do
          assert User.find(@user.id).credits.to_s == "1000"
        end
        
        should "match the users credits to the credit events virtual amount" do
          assert_equal User.find(@user.id).credits.to_s, assigns(:credit_event).virtualamount.to_s
        end
        
        should "match the user to the credit events user" do
          assert @user == assigns(:credit_event).user
        end

        should "not increase the number of credit events" do
          assert_equal 0, CreditEvent.count - @credit_event_count
        end
        
        should "not send an email" do
          assert_equal 0,  ActionMailer::Base.deliveries.size - @email_size, (ActionMailer::Base.deliveries - @emails)
        end
      end
    end
    
    context "passing a reversal" do
      setup do
        @credit_event_count = CreditEvent.count
        
        @hash = Digest::MD5.hexdigest([ultimate_pay_postback[:dtdatetime], ultimate_pay_postback[:login], 
                                      "yxZMXJfoRRN1pWRa", "P9aHbg8HSjPdqbbeSCrKk3Usf7p0xj", 
                                      @user.id, "ADMIN_REVERSAL", 
                                      ultimate_pay_postback[:set_amount], ultimate_pay_postback[:amount], 
                                      ultimate_pay_postback[:sepamount], ultimate_pay_postback[:currency], 
                                      ultimate_pay_postback[:sn], ultimate_pay_postback[:mirror], 
                                      ultimate_pay_postback[:pbctrans], ultimate_pay_postback[:developerid], 
                                      ultimate_pay_postback[:appid], ultimate_pay_postback[:virtualamount], 
                                      ultimate_pay_postback[:virtualcurrency]].join())
        post :postback, ultimate_pay_postback(:merchtrans => "credit-#{@token}", :userid => @user.id, :hash => @hash, :commtype => "ADMIN_REVERSAL")
      end

      should respond_with(:success)
      should respond_with_content_type('text/html')
      should_not render_with_layout
      
      should "render the correct text" do
        assert_response_contains("[OK]|")
        assert_response_contains("#{DateTime.now.strftime("%Y%m%d%H%M")}") #without the seconds
        assert_response_contains("|#{assigns(:credit_event).pbctrans}|[N/A]")
      end

      context "returns a credit_event that" do
        
        should assign_to(:credit_event) 
        
        should "not be nil? or a new_record" do
          assert_not_nil assigns(:credit_event)
          assert !assigns(:credit_event).new_record?
        end
      
        should "store the ultimate pay attributes" do
          assert assigns(:credit_event).site.present?
          assert assigns(:credit_event).commtype.present?
          assert assigns(:credit_event).currency.present?
          assert assigns(:credit_event).detail.present?
          assert assigns(:credit_event).timestamp.present?
          assert assigns(:credit_event).gwtid.present?
          assert assigns(:credit_event).livemode.present?
          assert assigns(:credit_event).login.present?
          assert assigns(:credit_event).mirror.present?
          assert assigns(:credit_event).payment_id.present?
          assert assigns(:credit_event).pbctrans.present?
          assert assigns(:credit_event).rescode.present?
          assert assigns(:credit_event).sepamount.present?
          assert assigns(:credit_event).set_amount.present?
          assert assigns(:credit_event).sn.present?
          assert assigns(:credit_event).virtualamount.present?
          assert assigns(:credit_event).amount.present?
        end
        
        should "have an OK status message" do
          assert_equal assigns(:credit_event).status_message, "[OK]"
        end
      end
      
      context "returns a hash that" do
        
        should assign_to(:hash) 
        
        should "match the passed in hash" do
          assert_equal @hash, assigns(:hash)
        end
      
      end
      
      should "update the user's credits" do
        assert User.find(@user.id).credits.to_s == "-1000"
      end
      
      should "match the users credits to the negative of the credit events virtual amount" do
        assert User.find(@user.id).credits.to_s == (0 - assigns(:credit_event).virtualamount.to_i).to_s
      end
      
      should "match the user to the credit events user" do
        assert @user == assigns(:credit_event).user
      end

      should "not increase the number of credit events" do
        assert_equal 0, CreditEvent.count - @credit_event_count
      end
      
      should "not send an email" do
        assert_equal 0, ActionMailer::Base.deliveries.size - @email_size
      end
    end

    context "passing the incorrect merchtrans" do
      setup do
        @credit_event_count = CreditEvent.count
        post :postback, ultimate_pay_postback(:merchtrans => "thisisincorrect", :userid => @user.id, :hash => @hash)
      end
      
      should respond_with(:success)
      should respond_with_content_type('text/html')
      should_not render_with_layout('application')
      should render_with_layout('email')
      
      should "render the correct text" do
        assert_response_contains("[ERROR]|")
        assert_response_contains("#{DateTime.now.strftime("%Y%m%d%H%M")}") #without the seconds
        assert_response_contains("|#{assigns(:credit_event).pbctrans}|could_not_find_credit_event_or_unknown_transaction_type")
      end

      context "returns a hash that" do
          
        should assign_to(:hash) 
        
        should "match the passed in hash" do
          assert_equal @hash, assigns(:hash)
        end
      
      end

      context "returns a credit_event that" do
        
        should assign_to(:credit_event) 
        
        should "not be nil? or a new_record" do
          assert_not_nil assigns(:credit_event)
          assert !assigns(:credit_event).new_record?
        end
      
        should "store the ultimate pay attributes" do
          assert assigns(:credit_event).site.present?
          assert assigns(:credit_event).commtype.present?
          assert assigns(:credit_event).currency.present?
          assert assigns(:credit_event).detail.present?
          assert assigns(:credit_event).timestamp.present?
          assert assigns(:credit_event).gwtid.present?
          assert assigns(:credit_event).livemode.present?
          assert assigns(:credit_event).login.present?
          assert assigns(:credit_event).mirror.present?
          assert assigns(:credit_event).payment_id.present?
          assert assigns(:credit_event).pbctrans.present?
          assert assigns(:credit_event).rescode.present?
          assert assigns(:credit_event).sepamount.present?
          assert assigns(:credit_event).set_amount.present?
          assert assigns(:credit_event).sn.present?
          assert assigns(:credit_event).virtualamount.present?
          assert assigns(:credit_event).amount.present?
        end
        
        should "have an Error status message" do
          assert_equal assigns(:credit_event).status_message, "[ERROR] Could not find credit event or unknown transaction type"
        end
        
        should "have a user because it's passed in the params" do
          assert assigns(:credit_event).user.present?, assigns(:credit_event).inspect
        end
      end

      should "increase the number of credit events" do
        assert_equal 1, CreditEvent.count - @credit_event_count
      end
      
      should "not increase the user's credits" do
        assert_equal User.find(@user.id).credits.to_s, "0"
      end
      
      should "send an email" do
         assert_equal 1, ActionMailer::Base.deliveries.size - @email_size
         invite_email = ActionMailer::Base.deliveries.last
           assert_not_nil invite_email, ActionMailer::Base.deliveries.inspect
         assert_equal invite_email.subject, "[IMPORTANT] Credit Event Error"
         assert_equal invite_email.to[0], 'info@buddydrinks.com'
      end
    end
    
    context "passing the correct merchtrans but no token" do
      setup do
        @credit_event_count = CreditEvent.count
        post :postback, ultimate_pay_postback(:merchtrans => "credit-", :userid => @user.id, :hash => @hash)
      end
      
      should respond_with(:success)
      should respond_with_content_type('text/html')
      should_not render_with_layout
      
      should "render the correct text" do
        assert_response_contains("[OK]|")
        assert_response_contains("#{DateTime.now.strftime("%Y%m%d%H%M")}") #without the seconds
        assert_response_contains("|#{assigns(:credit_event).pbctrans}|[N/A]")
      end

      context "returns a hash that" do
          
        should assign_to(:hash) 
        
        should "match the passed in hash" do
          assert_equal @hash, assigns(:hash)
        end
      
      end

      context "returns a credit_event that" do
        
        should assign_to(:credit_event) 
        
        should "not be nil? or a new_record" do
          assert_not_nil assigns(:credit_event)
          assert !assigns(:credit_event).new_record?
        end
      
        should "store the ultimate pay attributes" do
          assert assigns(:credit_event).site.present?
          assert assigns(:credit_event).commtype.present?
          assert assigns(:credit_event).currency.present?
          assert assigns(:credit_event).detail.present?
          assert assigns(:credit_event).timestamp.present?
          assert assigns(:credit_event).gwtid.present?
          assert assigns(:credit_event).livemode.present?
          assert assigns(:credit_event).login.present?
          assert assigns(:credit_event).mirror.present?
          assert assigns(:credit_event).payment_id.present?
          assert assigns(:credit_event).pbctrans.present?
          assert assigns(:credit_event).rescode.present?
          assert assigns(:credit_event).sepamount.present?
          assert assigns(:credit_event).set_amount.present?
          assert assigns(:credit_event).sn.present?
          assert assigns(:credit_event).virtualamount.present?
          assert assigns(:credit_event).amount.present?
        end
        
        should "have an ok status message" do
          assert_equal assigns(:credit_event).status_message, "[OK]"
        end
        
        should "have a user because it's passed in the params" do
          assert assigns(:credit_event).user.present?, assigns(:credit_event).inspect
        end
        
        should "not have a token" do
          assert_nil assigns(:credit_event).token
        end
      end

      should "increase the number of credit events" do
        assert_equal 1, CreditEvent.count - @credit_event_count
      end
      
      should "update the user's credits" do
        assert User.find(@user.id).credits.to_s == "1000"
      end
      
      should "match the users credits to the credit events virtual amount" do
        assert_equal User.find(@user.id).credits.to_s, assigns(:credit_event).virtualamount.to_s
      end
      
      should "match the user to the credit events user" do
        assert @user == assigns(:credit_event).user
      end
      
      should "not send an email" do
        assert_equal 0,  ActionMailer::Base.deliveries.size - @email_size, (ActionMailer::Base.deliveries - @emails)
      end
    end
    
    context "passing the incorrect userid" do
      setup do
        @credit_event_count = CreditEvent.count
        @hash = Digest::MD5.hexdigest([ultimate_pay_postback[:dtdatetime], ultimate_pay_postback[:login], 
                                    "yxZMXJfoRRN1pWRa", "P9aHbg8HSjPdqbbeSCrKk3Usf7p0xj", 
                                    "", ultimate_pay_postback[:commtype], 
                                    ultimate_pay_postback[:set_amount], ultimate_pay_postback[:amount], 
                                    ultimate_pay_postback[:sepamount], ultimate_pay_postback[:currency], 
                                    ultimate_pay_postback[:sn], ultimate_pay_postback[:mirror], 
                                    ultimate_pay_postback[:pbctrans], ultimate_pay_postback[:developerid], 
                                    ultimate_pay_postback[:appid], ultimate_pay_postback[:virtualamount], 
                                    ultimate_pay_postback[:virtualcurrency]].join())
        post :postback, ultimate_pay_postback(:merchtrans => "credit-#{@token}", :userid => "", :hash => @hash)
      end
      
      should respond_with(:success)
      should respond_with_content_type('text/html')
      should_not render_with_layout('application')
      should render_with_layout('email')
      
      should "render the correct text" do
        assert_response_contains("[ERROR]|")
        assert_response_contains("#{DateTime.now.strftime("%Y%m%d%H%M")}") #without the seconds
        assert_response_contains("|#{assigns(:credit_event).pbctrans}|user_not_present_or_doesn_t_exist")
      end

      context "returns a hash that" do
          
        should assign_to(:hash) 
        
        should "match the passed in hash" do
          assert_equal @hash, assigns(:hash)
        end
      
      end

      context "returns a credit_event that" do
        
        should assign_to(:credit_event) 
        
        should "not be nil? or a new_record" do
          assert_not_nil assigns(:credit_event)
          assert !assigns(:credit_event).new_record?
        end
      
        should "store the ultimate pay attributes" do
          assert assigns(:credit_event).site.present?
          assert assigns(:credit_event).commtype.present?
          assert assigns(:credit_event).currency.present?
          assert assigns(:credit_event).detail.present?
          assert assigns(:credit_event).timestamp.present?
          assert assigns(:credit_event).gwtid.present?
          assert assigns(:credit_event).livemode.present?
          assert assigns(:credit_event).login.present?
          assert assigns(:credit_event).mirror.present?
          assert assigns(:credit_event).payment_id.present?
          assert assigns(:credit_event).pbctrans.present?
          assert assigns(:credit_event).rescode.present?
          assert assigns(:credit_event).sepamount.present?
          assert assigns(:credit_event).set_amount.present?
          assert assigns(:credit_event).sn.present?
          assert assigns(:credit_event).virtualamount.present?
          assert assigns(:credit_event).amount.present?
        end
        
        should "have an Error status message" do
          assert_equal assigns(:credit_event).status_message, "[ERROR] User not present or doesn't exist"
        end
        
        should "not have a user" do
          assert assigns(:credit_event).user.blank?
        end
      end

      should "increase the number of credit events" do
        assert_equal 1, CreditEvent.count - @credit_event_count
      end
      
      should "not increase the user's credits" do
        assert_equal User.find(@user.id).credits.to_s, "0"
      end
      
      should "send an email" do
         assert_equal 1, ActionMailer::Base.deliveries.size - @email_size
         invite_email = ActionMailer::Base.deliveries.last
           assert_not_nil invite_email, ActionMailer::Base.deliveries.inspect
         assert_equal invite_email.subject, "[IMPORTANT] Credit Event Error"
         assert_equal invite_email.to[0], 'info@buddydrinks.com'
      end
    end
    
    context "passing the incorrect hash" do
      setup do
        @credit_event_count = CreditEvent.count
        post :postback, ultimate_pay_postback(:merchtrans => "credit-#{@token}", :userid => @user.id, :hash => "Incorrecthash")
      end
      
      should respond_with(:success)
      should respond_with_content_type('text/html')
      should_not render_with_layout('application')
      should render_with_layout('email')
      
      should "render the correct text" do
        assert_response_contains("[ERROR]|")
        assert_response_contains("#{DateTime.now.strftime("%Y%m%d%H%M")}") #without the seconds
        assert_response_contains("|#{assigns(:credit_event).pbctrans}|hash_does_not_match")
      end

      context "returns a hash that" do
          
        should assign_to(:hash) 
        
        should "not match the passed in hash" do
          assert "Incorrecthash" != assigns(:hash)
        end
      
      end

      context "returns a credit_event that" do
        
        should assign_to(:credit_event) 
        
        should "not be nil? or a new_record" do
          assert_not_nil assigns(:credit_event)
          assert !assigns(:credit_event).new_record?
        end
      
        should "store the ultimate pay attributes" do
          assert assigns(:credit_event).site.present?
          assert assigns(:credit_event).commtype.present?
          assert assigns(:credit_event).currency.present?
          assert assigns(:credit_event).detail.present?
          assert assigns(:credit_event).timestamp.present?
          assert assigns(:credit_event).gwtid.present?
          assert assigns(:credit_event).livemode.present?
          assert assigns(:credit_event).login.present?
          assert assigns(:credit_event).mirror.present?
          assert assigns(:credit_event).payment_id.present?
          assert assigns(:credit_event).pbctrans.present?
          assert assigns(:credit_event).rescode.present?
          assert assigns(:credit_event).sepamount.present?
          assert assigns(:credit_event).set_amount.present?
          assert assigns(:credit_event).sn.present?
          assert assigns(:credit_event).virtualamount.present?
          assert assigns(:credit_event).amount.present?
        end
        
        should "have an Error status message" do
          assert_equal assigns(:credit_event).status_message, "[ERROR] Hash does not match"
        end
        
        should "have a user" do
          assert assigns(:credit_event).user.present?
        end
      end

      should "not increase the number of credit events" do
        assert_equal 0, CreditEvent.count - @credit_event_count
      end
      
      should "not increase the user's credits" do
        assert_equal User.find(@user.id).credits.to_s, "0"
      end
      
      should "send an email" do
         assert_equal 1, ActionMailer::Base.deliveries.size - @email_size
         invite_email = ActionMailer::Base.deliveries.last
           assert_not_nil invite_email, ActionMailer::Base.deliveries.inspect
         assert_equal invite_email.subject, "[IMPORTANT] Credit Event Error"
         assert_equal invite_email.to[0], 'info@buddydrinks.com'
      end
    end
    
    context "for an existing credit event" do
      setup do
        @credit_event = Factory(:credit_event, :pbctrans => ultimate_pay_postback[:pbctrans])
        @credit_event_count = CreditEvent.count
      end
      
      context "passing the correct parameters" do
        setup do
          post :postback, ultimate_pay_postback(:merchtrans => "credit-#{@token}", :userid => @user.id, :hash => @hash, :pbctrans => @credit_event.pbctrans)
        end

        should respond_with(:success)
        should respond_with_content_type('text/html')
        should_not render_with_layout
      
        should "render the correct text" do
          assert_response_contains("[OK]|")
          assert_response_contains("#{DateTime.now.strftime("%Y%m%d%H%M")}") #without the seconds
          assert_response_contains("|#{assigns(:credit_event).pbctrans}|[N/A]")
        end

        context "returns a credit_event that" do
        
          should assign_to(:credit_event) 
        
          should "not be nil? or a new_record" do
            assert_not_nil assigns(:credit_event)
            assert !assigns(:credit_event).new_record?
          end
      
          should "store the ultimate pay attributes" do
            assert assigns(:credit_event).site.present?
            assert assigns(:credit_event).commtype.present?
            assert assigns(:credit_event).currency.present?
            assert assigns(:credit_event).detail.present?
            assert assigns(:credit_event).timestamp.present?
            assert assigns(:credit_event).gwtid.present?
            assert assigns(:credit_event).livemode.present?
            assert assigns(:credit_event).login.present?
            assert assigns(:credit_event).mirror.present?
            assert assigns(:credit_event).payment_id.present?
            assert assigns(:credit_event).pbctrans.present?
            assert assigns(:credit_event).rescode.present?
            assert assigns(:credit_event).sepamount.present?
            assert assigns(:credit_event).set_amount.present?
            assert assigns(:credit_event).sn.present?
            assert assigns(:credit_event).virtualamount.present?
            assert assigns(:credit_event).amount.present?
          end
        
          should "have an OK status message" do
            assert_equal assigns(:credit_event).status_message, "[OK]", [assigns(:hash), @hash].join(" ")
          end
        end
      
        context "returns a hash that" do
        
          should assign_to(:hash) 
        
          should "match the passed in hash" do
            assert_equal @hash, assigns(:hash)
          end
      
        end
      
        should "update the user's credits" do
          assert_equal User.find(@user.id).credits.to_s, "1000", User.find(@user.id).credits.to_s
        end
      
        should "match the users credits to the credit events virtual amount" do
          assert_equal assigns(:credit_event).virtualamount.to_s, User.find(@user.id).credits.to_s
        end
      
        should "match the user to the credit events user" do
          assert @user == assigns(:credit_event).user
        end

        should "not increase the number of credit events" do
          assert_equal 0, CreditEvent.count - @credit_event_count
        end
        
        should "not send an email" do
          assert_equal 0, ActionMailer::Base.deliveries.size - @email_size, ActionMailer::Base.deliveries.last.inspect
        end
      end # passing correct parameters
      
      context "passing the incorrect hash" do
        setup do
          post :postback, ultimate_pay_postback(:merchtrans => "credit-#{@token}", :userid => @user.id, :hash => "Incorrecthash", :pbctrans => @credit_event.pbctrans)
        end

        should respond_with(:success)
        should respond_with_content_type('text/html')
        should_not render_with_layout('application')
        should render_with_layout('email')
      
        should "render the correct text" do
          assert_response_contains("[OK]|")
          assert_response_contains("#{DateTime.now.strftime("%Y%m%d%H%M")}") #without the seconds
          assert_response_contains("|#{assigns(:credit_event).pbctrans}|[N/A]")
        end

        context "returns a credit_event that" do
        
          should assign_to(:credit_event) 
        
          should "not be nil? or a new_record" do
            assert_not_nil assigns(:credit_event)
            assert !assigns(:credit_event).new_record?
          end
      
          should "store the ultimate pay attributes" do
            assert assigns(:credit_event).site.present?
            assert assigns(:credit_event).commtype.present?
            assert assigns(:credit_event).currency.present?
            assert assigns(:credit_event).detail.present?
            assert assigns(:credit_event).timestamp.present?
            assert assigns(:credit_event).gwtid.present?
            assert assigns(:credit_event).livemode.present?
            assert assigns(:credit_event).login.present?
            assert assigns(:credit_event).mirror.present?
            assert assigns(:credit_event).payment_id.present?
            assert assigns(:credit_event).pbctrans.present?
            assert assigns(:credit_event).rescode.present?
            assert assigns(:credit_event).sepamount.present?
            assert assigns(:credit_event).set_amount.present?
            assert assigns(:credit_event).sn.present?
            assert assigns(:credit_event).virtualamount.present?
            assert assigns(:credit_event).amount.present?
          end
        
          should "have an Error status message" do
            assert_equal assigns(:credit_event).status_message, "[ERROR] Hash does not match"
          end
        end
      
        context "returns a hash that" do
        
          should assign_to(:hash) 
        
          should "not match the passed in hash" do
            assert "Incorrecthash" != assigns(:hash)
          end
      
        end
      
        should "not update the user's credits" do
          assert User.find(@user.id).credits.to_s == "0"
        end
      
        should "not match the users credits to the credit events virtual amount" do
          assert User.find(@user.id).credits.to_s != assigns(:credit_event).virtualamount.to_s
        end
      
        should "match the user to the credit events user" do
          assert @user == assigns(:credit_event).user
        end

        should "not increase the number of credit events" do
          assert_equal 0, CreditEvent.count - @credit_event_count
        end
        
        should "send an email" do
           assert_equal 1, ActionMailer::Base.deliveries.size - @email_size, "Actionmailer: #{ActionMailer::Base.deliveries.size} Emails: #{@emails.size}"
           
         invite_email = ActionMailer::Base.deliveries.last
           assert_not_nil invite_email, ActionMailer::Base.deliveries.inspect
           assert_equal invite_email.subject, "[IMPORTANT] Credit Event Error", (ActionMailer::Base.deliveries - @emails)
           assert_equal invite_email.to[0], 'info@buddydrinks.com'
        end
      end # passing incorrect hash
    end
    
    context "passing in an unknonwn credit event" do
      setup do
        @credit_event_count = CreditEvent.count
        post :postback, ultimate_pay_postback(:merchtrans => "", :userid => @user.id, :hash => @hash)
      end
      
      should respond_with(:success)
      should respond_with_content_type('text/html')
      should_not render_with_layout('application')
      should render_with_layout('email')
      
      should "render the correct text" do
        assert_response_contains("[ERROR]|")
        assert_response_contains("#{DateTime.now.strftime("%Y%m%d%H%M")}") #without the seconds
        assert_response_contains("|#{assigns(:credit_event).pbctrans}|could_not_find_credit_event_or_unknown_transaction_type")
      end

      context "returns a hash that" do
          
        should assign_to(:hash) 
        
        should "match the passed in hash" do
          assert_equal @hash, assigns(:hash)
        end
      
      end

      context "returns a credit_event that" do
        
        should assign_to(:credit_event) 
        
        should "not be nil? or a new_record" do
          assert_not_nil assigns(:credit_event)
          assert !assigns(:credit_event).new_record?
        end
      
        should "store the ultimate pay attributes" do
          assert assigns(:credit_event).site.present?
          assert assigns(:credit_event).commtype.present?
          assert assigns(:credit_event).currency.present?
          assert assigns(:credit_event).detail.present?
          assert assigns(:credit_event).timestamp.present?
          assert assigns(:credit_event).gwtid.present?
          assert assigns(:credit_event).livemode.present?
          assert assigns(:credit_event).login.present?
          assert assigns(:credit_event).mirror.present?
          assert assigns(:credit_event).payment_id.present?
          assert assigns(:credit_event).pbctrans.present?
          assert assigns(:credit_event).rescode.present?
          assert assigns(:credit_event).sepamount.present?
          assert assigns(:credit_event).set_amount.present?
          assert assigns(:credit_event).sn.present?
          assert assigns(:credit_event).virtualamount.present?
          assert assigns(:credit_event).amount.present?
        end
        
        should "have an Error status message" do
          assert_equal assigns(:credit_event).status_message, "[ERROR] Could not find credit event or unknown transaction type"
        end
        
        should "have a user because it's passed in the params" do
          assert assigns(:credit_event).user.present?, assigns(:credit_event).inspect
        end
      end

      should "increase the number of credit events" do
        assert_equal 1, CreditEvent.count - @credit_event_count
      end
      
      should "not increase the user's credits" do
        assert_equal User.find(@user.id).credits.to_s, "0"
      end
      
      should "send an email" do
         assert_equal 1, ActionMailer::Base.deliveries.size - @email_size
         
         invite_email = ActionMailer::Base.deliveries.last
           assert_not_nil invite_email, ActionMailer::Base.deliveries.inspect
         assert_equal invite_email.subject, "[IMPORTANT] Credit Event Error"
         assert_equal invite_email.to[0], 'info@buddydrinks.com'
      end
    end # passing in an unknown event
  end
  
  # balance
  context "on GET to balance" do
    setup { get :balance, :user_id => Factory(:user).id }
    
    should assign_to(:user)
    should respond_with(:success)
    should_not render_with_layout
    should respond_with_content_type('text/html')
    
    should "respond with user's credits" do
      assert_response_equals("0")
    end
  end
  
  # Paying for Ious with virtual currency
  # create
  context "POST to create" do    
    context "and paying for an iou" do
      setup do
        @price = Factory(:price)
        @iou = Factory(:iou, :price => @price)
        @user = Factory(:customer, :credits => "10000")
        sign_in(@user)
        @credit_event_count = CreditEvent.count
        @delayed_job_count = Delayed::Job.count
        @email_count = ActionMailer::Base.deliveries.length
        post :create, :user_id => @user.id, :credit_event => { :user_id => @user.id, :iou_id => @iou.id, :amount => @iou.cents, :currency => @iou.currency, :provider => "Buddy Bucks", :site_id => @iou.site_id, :virtualamount => @iou.price_in_bucks, :commtype => "PURCHASE" }
      end

      should respond_with(:success)
      should assign_to(:credit_event)
      should assign_to(:user)
      should assign_to(:current_user)
      should_not render_with_layout('application')
      should render_with_layout('email')
      should respond_with_content_type('text/html')

      should "increase the number of credit events" do
        assert_equal 1, CreditEvent.count - @credit_event_count
      end

      should "increase the number of delayed job" do
        assert_equal 3, Delayed::Job.count - @delayed_job_count, Delayed::Job.order('created_at desc').first(3).inspect # sets the expiration job and 2 reminder job
      end

      should "increase the number of emails" do
        assert_equal 1, ActionMailer::Base.deliveries.length - @email_count
      end

      should "not have a new record as credit event" do
        assert !assigns(:credit_event).new_record?
      end

      should "have the iou be paid" do
        assert assigns(:credit_event).iou.paid?
      end
      
      should "have an OK response" do
        assert_response_equals("OK")
      end
      
      should "debit the user's credits" do
        assert_equal 10000 - @iou.price_in_bucks.to_i, User.find(@user.id).credits.to_i
      end
    end # and paying for an iou
    
    context "and paying without enough credits" do
      setup do
        @price = Factory(:price)
        @iou = Factory(:iou, :price => @price)
        @user = Factory(:customer, :credits => "1")
        sign_in(@user)
        @credit_event_count = CreditEvent.count
        @delayed_job_count = Delayed::Job.count
        @email_count = ActionMailer::Base.deliveries.length
        post :create, :user_id => @user.id, :credit_event => { :user_id => @user.id, :iou_id => @iou.id, :amount => @iou.cents, :currency => @iou.currency, :provider => "Buddy Bucks", :site_id => @iou.site_id, :virtualamount => @iou.price_in_bucks, :commtype => "PURCHASE" }
      end

      should respond_with(:error)
      should assign_to(:credit_event)
      should assign_to(:user)
      should assign_to(:current_user)
      should_not render_with_layout
      should respond_with_content_type('text/html')

      should "not increase the number of credit events" do
        assert_equal 0, CreditEvent.count - @credit_event_count
      end

      should "not increase the number of delayed job" do
        assert_equal 0, Delayed::Job.count - @delayed_job_count # sets the expiration job
      end

      should "not increase the number of emails" do
        assert_equal 0, ActionMailer::Base.deliveries.length - @email_count
      end

      should "have a new record as credit event" do
        assert assigns(:credit_event).new_record?
      end

      should "not have the iou be paid" do
        assert !assigns(:credit_event).iou.paid?
      end
      
      should "have an ERROR response" do
        assert_response_equals("ERROR: false")
      end
      
      should "not debit the user's credits" do
        assert_equal 1, User.find(@user.id).credits.to_i
      end
    end # and paying without enough credits    
  end # post to create


  private

  def social_gold_postback(options={})
    { :pegged_currency_amount_iso_currency_code => "USD", :premium_currency_amount => "5000", :offer_id => "nvdo9h70w2i5eum8a9ra4og2b",
      :socialgold_transaction_id => "8179529fe03c6d58ef04ef53ceb8a5fc", :net_payout_amount => "549", :cc_token => "t7evqmnzjyvos4y3776diqm8sltc4jf",
      :billing_country_code => "US", :simulated => true, :pegged_currency_amount => 611, :offer_amount => 500, :socialgold_transaction_status => "SUCCESS",
      :amount => 500, :pegged_currency_label => "USD", :version => 1, :premium_currency_label => "Buddy Beers Bucks",
      :offer_amount_iso_currency_code => "EUR", :billing_zip => 98121, :user_id => 6, :user_balance => 500, :event_type => "BOUGHT_CURRENCY",
      :external_ref_id => ious(:pending_payment_voucher).id, :timestamp => "1278000045", :signature => "9dbb5d82ccf1f96eb0c07558bb71d47f" }.merge(options)
  end
  
  def ultimate_pay_postback(options={})
    { :login => "mSXJJPcFHs", :adminpwd => "yxZMXJfoRRN1pWRa", :dtdatetime => DateTime.now.strftime("%Y%m%d%H%M%S"), :pbctrans => "{8873b125-d622-4d2d-9395-c0151edf189e}",
      :sn => "BEER", :appid => "buddybeers", :commtype => "PAYMENT", :currency => "EUR", :detail => "SINGLE_PURCHASE", :set_amount => "8.60", :amount => "0.00",
      :sepamount => "10.00", :userid => "6", :accountname => "travis", :livemode => "T", :paymentid => "N/A", :pkgid => "N/A", :merchtrans => "credit-#{String.tokenize}", 
      :mirror => "N/A", :rescode => "N/A", :gwtid => "N/A", :virtualamount => "1000", :virtualcurrency => "BUDDYB", :hash => "d7b1d1013632ddd6e41449cd8f079d1b"    
    }.merge(options)
  end
end
