class CreditsController < ApplicationController

  # This controller handles everything involved with the Ultimate Pay (Buddy Bucks) payments
  protect_from_forgery :except => [:postback]
  
  before_filter :authenticate_user!, :only => [:index]
  before_filter :get_user, :except => [:postback, :index]
  layout "new_application"
  # here are actions for purchasing with virtual currency API
  
  def create
    @credit_event = CreditEvent.new(params[:credit_event])
    
    # this is a fail safe. We should also perform this check on the client side.
    if @credit_event.user.credits.to_i >= @credit_event.iou.price_in_bucks
      if @credit_event.save and @credit_event.iou.valid?
        @credit_event.iou.paid! unless @credit_event.iou.paid?
        post_to_facebook(@credit_event.iou)
        render :text => "OK", :status => 200
      else
        render :text => "ERROR: #{@credit_event.errors.full_messages}", :status => 500
      end
    else
      render :text => "ERROR: #{@credit_event.user.credits.to_i >= @credit_event.iou.price_in_bucks}", :status => 500
    end
  end

  # Below is stuff for buying virtual currency

  def index
    @user = current_user
    @transaction_token = String.tokenize
    # amounts to charge: 
    @amounts = ["10.00", "20.00", "30.00", "40.00", "50.00"]
    @amounts = @amounts.collect{ |a| {:amount => a, :hash => Digest::MD5.hexdigest([current_user.id.to_s, account_password, account_secret, "USD", a, "credit-#{@transaction_token}", current_site.code_name].join())} }
  end

  # GET to on successful sale through Ultimate Pay
  def success
    # Here we pass in a token as the id so that we can match it later with the postback
    @credit_event = CreditEvent.find_or_create_by_token_and_user_id(:token => params[:id], :user_id => @user.id)
    
    # UltimatePay sends:
    # "token" => "B4G7oLcLInsSo4E18XdPlmPCe9TVg9noOPWEH3yoeND" # no idea what this token is ... 
    # "noLb" => "1"
    
    @credit_event.update_attributes(:no_lib => params['noLb'], :provider => "UltimatePay")
    flash[:notice] = t("credits.success.success")
    redirect_to user_credits_url(@user)
  end

  # POSTED to on successful sale of virtual currency or iou through UltimatePay
  def postback
    expire_page :controller => 'home', :action => 'index'
    
    # accountname - User's account name as defined in merchant's system (if previously sent to UPay) - johndoe408 - AN, 75
    # adminpwd - PlaySpan-provided admin password - Aci4sh5skhGsklj283 - AN, 20
    # appid - Merchant-defined application ID. Same as above - betagame - AN, 128
    # commtype - PAYMENT, ADMIN_REVERSAL, FORCED_REVERSAL - PAYMENT - A, 20
    # currency - ISO 3-letter currency code. Default is "USD" for US Dollars. See ISO 4217 - USD - A, 3
    # detail - Additional details associated with the commtype - SUBSCRIPTION - A, 20
    # dtdatetime - Datetime in YYYYMMDDHHMMSS format, EST timezone - 20100813214224 - N, 14
    # gwtid - Internal use only        
    # hash (back-end) - An MD5 hash based on the variables included in our POST to you. See back-end hash for the hash construction. - 5f9ae151091b057a100adcc4d9a5e1a2 - AN, 32
    # livemode - Indicates whether a transaction was in live mode ("T") or test ("F") - T    
    # login - Internal use only - NAE0M6tkNx - AN, 20
    # merchtrans - Merchant-defined unique transaction or order ID. Same as above. - US-131827-20101019232716   
    #             - We pass in order-12345 or credit-12345666443 where the first part describes the object being puchased, either
    #               an iou or virtual currency. the second param is the order id or the credit token
    # mirror - Custom data that you would like to be mirrored back with all notifications.  This value must be URL-encoded to eliminate characters disallowed in URL strings. Passed in on original transaction. - orderbegintime=1286602659&itemid=239427    
    # paymentid - 2-letter payment method ID. - CH - Same as above
    # pbctrans - PlaySpan's unique transaction ID - {32d5d327-270b-4e3b-89b9-03b53130c4b1} - AN, 38
    # rescode - Internal use only        
    # sepamount - Amount collected from the user (default currency is US dollar). - 6.99 - Same as above.
    # set_amount - Amount to be settled to merchant (payment to us!).  Will be negative if reflecting a reversal or refund. - 7.15 - N, 11
    # sn - 4-letter UltimatePay service name that is assigned by PlaySpan. Same as above - ACME   
    # userid - Merchant-defined unique user ID. Same as above - 131827 - AN, 50 
    
    # For all credit events I want to track them and save them locally
    #curl -d "pegged_currency_amount_iso_currency_code=USD&premium_currency_amount=50000&timestamp=1278000045&simulated=true&socialgold_transaction_id=5da8a17ac88d917890fc5070e6e700a3&signature=9dbb5d82ccf1f96eb0c07558bb71d47f&amount=50000&pegged_currency_amount=611&socialgold_transaction_status=SUCCESS&net_payout_amount=549&cc_token=t7evqmnzjyvos4y3776diqm8sltc4jf&billing_country_code=US&pegged_currency_label=USD&version=1&user_id=6&offer_amount=500&premium_currency_label=Buddy%20Beers%20Bucks&billing_zip=98121&offer_amount_iso_currency_code=EUR&event_type=BOUGHT_CURRENCY&external_ref_id=&offer_id=nvdo9h70w2i5eum8a9ra4og2b&user_balance=100180" "http://localhost:3000/credits/postback"

    # Validate the post:
    # 
    # MD5 Hash Digest (back-end):
    # 
    # We return a hash of our own when communicating with you. The order of the concatenated strings (including optional parameters), 
    # is dtdatetime, login, adminpwd, merchant authentication phrase (aka secret), userid, commtype, set_amount, amount, sepamount, 
    # currency, sn, mirror, pbctrans, developerid, appid, virtualamount, virtualcurrency.
    #
    # How to Respond to the Postback:
    # 
    # When UltimatePay makes the POST request to your Postback URL, it expects the HTTP response "Content-type" to be "text/plain" 
    # and the entire response on one line.  Each response text string has four components separated by a "pipe" character ("|").  
    # There shall never be a pipe embedded in any of the response comments.
    # 
    # Result Code   Must be "[OK]" or "[ERROR]".  Any response that isn't prefixed with ?"[OK]" will be interpreted as an error.
    # [OK] indicates that the POSTBACK was accepted
    # [ERROR] indicates the POSTBACK could not be processed and must be resubmitted, potentially with corrections, at a later time.  
    #         A lack of response shall be interpreted as an [ERROR]
    # Date/time - Your system's local date and time when the POSTBACK was received
    # PBCTrans - PlaySpan's unique transaction ID
    # Reason Code - ?URL-encoded string indicating the reason(s) for the ERROR result code, if applicable.  A tilde ("~") may be 
    # used to delimit multiple reasons. If the Result Code is [OK], then the Reason code should be passed as ?"[N/A]". 
    #
    # Response to a valid transaction
    # 
    # Format
    # [OK]|YYYYMMDDHHMMSS|pbctrans|[N/A]
    # 
    # Example
    # [OK]|20100813204227|{32d5d327-270b-4e3b-89b9-03b53130c4b1}|[N/A]
    # Response to an invalid transaction
    # 
    # Format
    # [ERROR]|YYYYMMDDHHMMSS|pbctrans|Reason_for_error_with_no_spaces
    # 
    # Example
    # [ERROR]|20100818104134|{5546a9a3-cb87-4552-bbda-d5e6d3417b98}|Blacklisted_user
    #
    # Warning:
    # In the event we post a communication to you and do not receive an [OK] response back, our systems will retry the communication 
    # using the pbctrans value originally used. This ensures that you have the information you need to discard duplicates! If you have 
    # already received that transaction, you should simply return an [OK] and then discard the transaction. Your system should NOT return 
    # [ERROR] as this would trigger our system to retry yet again.
    
    # create the hash that UltimatePay is expecting
    hash_string = [params[:dtdatetime], params[:login], account_password, account_secret, 
                  params[:userid], params[:commtype], params[:set_amount], params[:amount], params[:sepamount], 
                  params[:currency], params[:sn], params[:mirror], params[:pbctrans], params[:developerid], 
                  params[:appid], params[:virtualamount], params[:virtualcurrency]].join()
    
    @hash = Digest::MD5.hexdigest(hash_string)
    
    # Find Credit Event by previously posted pbctransaction
    if @credit_event = CreditEvent.find_by_pbctrans(params[:pbctrans])
      
      # store the passed in attributes
      store_credit_event_attributes
      
      # if the payment was successful and the hashes match, update user's credits and update the credit event with the appropriate message
      if hash_matches?
        if update_users_credits
          @credit_event.update_attribute(:status_message, "[OK]")
        else
          @credit_event.update_attribute(:status_message, "[ERROR] Error updating users credits")
          Notifier.credit_event_error(@credit_event, params, "Very Important! The user has likely paid for their credits but not received them. The credit event was found from a previous transaction (or error) but there was an error updating the user's credits", 2).deliver
        end
      else
        @credit_event.update_attribute(:status_message, "[ERROR] Hash does not match")
        Notifier.credit_event_error(@credit_event, params, "Very Important! The user has likely paid for their credits but not received them. The credit event was found from a previous transaction (or error) but there was an error matching the hash. The generated hash was: #{@hash}", 2).deliver
      end
      
      # We have to return an OK response here otherwise Ultimatepay will continuously postback this information
      ultimate_pay_response("[OK]")
    
    # if the transaction is for virtual currency:  
    elsif params[:merchtrans].split("-")[0] == "credit"
    
      # find the credit event from the token and the user id. if there is none, create it
      @credit_event = CreditEvent.find_or_create_by_token_and_user_id(:token => params[:merchtrans].split("-")[1], :user_id => params[:userid])
      
      # if it was found and there is a user
      if @credit_event.user.present?
      
        # store the passed in attributes
        store_credit_event_attributes
      
        # if the payment was successful and the hashes match update user's credits and return appropriate response
        if hash_matches?
          if update_users_credits
            @credit_event.update_attribute(:status_message, "[OK]")
            ultimate_pay_response("[OK]")
          else
            @credit_event.update_attribute(:status_message, "[ERROR] Error updating users credits")
            ultimate_pay_response("[ERROR]", "Error updating users credits")
            Notifier.credit_event_error(@credit_event, params, "The credit event was found but there was an error updating the user's credits", 1).deliver
          end
        else
          @credit_event.update_attribute(:status_message, "[ERROR] Hash does not match")
          ultimate_pay_response("[ERROR]", "Hash does not match")
          Notifier.credit_event_error(@credit_event, params, "The credit event was found but there was an error matching the hash. The generated hash was: #{@hash}", 1).deliver
        end
      else
        @credit_event.update_attributes(:provider => "UltimatePay", :status_message => "[ERROR] User not present or doesn't exist")
        store_credit_event_attributes
        ultimate_pay_response("[ERROR]", "User not present or doesn't exist")
        Notifier.credit_event_error(@credit_event, params, " User not present or doesn't exist. The token was: #{params[:merchtrans].split("-")[1]} The user id was: #{params[:userid]}", 1).deliver
      end
    else
      @credit_event = CreditEvent.create(:provider => "UltimatePay", :status_message => "[ERROR] Could not find credit event or unknown transaction type")
      # store the passed in attributes
      store_credit_event_attributes
      ultimate_pay_response("[ERROR]", "Could not find credit event or unknown transaction type")
      Notifier.credit_event_error(@credit_event, params, "The credit event was not found from a previous transaction or the merchtrans param didn't contain the word credit. The merchtrans was: #{params[:merchtrans]}", 1).deliver
    end
  end

  def balance
    render :text => @user.credits
  end

  private
    def get_user
      @user = User.find(params[:user_id])
    end
    
    def store_credit_event_attributes
      # store the passed in attributes
      @credit_event.update_attributes(
                      :site => Site.find_by_code_name(params[:appid]),
                      :commtype => params[:commtype],
                      :currency => params[:currency],
                      :detail => params[:detail],
                      :timestamp => params[:dtdatetime],
                      :gwtid => params[:gwtid],
                      :livemode => params[:livemode],
                      :login => params[:login],
                      :mirror => params[:mirror],
                      :payment_id => params[:paymentid],
                      :pbctrans => params[:pbctrans],
                      :rescode => params[:rescode],
                      :sepamount => params[:sepamount],
                      :set_amount => params[:set_amount],
                      :sn => params[:sn],
                      :virtualamount => params[:virtualamount],
                      :amount => params[:amount]
                      )
      @credit_event.update_attribute(:user_id, params[:userid]) if @credit_event.user.blank?  
    end
    
    def hash_matches?    
      params[:hash] == @hash
    end
    
    def update_users_credits
      # update the user's credits
      if ["ADMIN_REVERSAL", "FORCED_REVERSAL"].include?(params[:commtype])
        @credit_event.user.debit!(params[:virtualamount])
      elsif params[:commtype] == "PAYMENT"
        @credit_event.user.credit!(params[:virtualamount])
      end
    end
    
    def ultimate_pay_response(status, message=nil)
      # [ERROR]|YYYYMMDDHHMMSS|pbctrans|Reason_for_error_with_no_spaces
      render :text => [status, DateTime.now.strftime("%Y%m%d%H%M%S"), @credit_event.present? ? @credit_event.pbctrans : params[:pbctrans], message.nil? ? "[N/A]" : message.parameterize.gsub("-", "_")].join("|")
    end
    
    def account_password
      "yxZMXJfoRRN1pWRa"
    end
    
    def account_secret
      "P9aHbg8HSjPdqbbeSCrKk3Usf7p0xj"
    end

end
