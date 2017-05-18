class PaypalController < ApplicationController
  
  require 'iconv'
  
  protect_from_forgery :except => [:create]
  
  layout false
  
  after_filter :change_paid_status, :only => [:complete]
  # Controller for paypal digital goods. Removing from ious controller.
  
  # POST
  def create
    paypal = PaypalDigitalGoods.new
    options = {}
    options.merge!(params[:options]) if params[:options].present?
    logger.debug("!!!!!!!!!!!!! #{options.inspect} #{params[:options]} !!!!!!!!!!!!!")
    result = paypal.set_express_checkout(params[:order_id], params[:amt], params[:cur], "#{params[:name]}: #{params[:description]}", params[:description], "1", options)
    
    # if not successful show what went wrong
    if result['ACK'] != "Success"
      render :text => result.inspect
    else     
      # Redirect to paypal.com in lightbox frame
      token = CGI::unescape(result['TOKEN'])
      paypal_url = paypal.get_paypal_url(token)
      redirect_to paypal_url
    end
  end  
  
  # POST
  def confirmation
    @iou = Iou.find(params[:order_id])
    
    paypal = PaypalDigitalGoods.new
    # TODO: Add description here
    result = paypal.do_express_checkout_payment(@iou.id, params[:amt], params[:cur], "Order ##{@iou.id}", 
                                                I18n.t("ious.paypal_payment.form.item_name", :amount => [@iou.amount.currency.symbol, @iou.amount].join(), :beers => [@iou.quantity, @iou.brand_name, @iou.beer_name].join(" "), :location => " #{t("global.at")} #{@iou.bar.name}"), 
                                                "1", params[:token], params['PayerID'])
    
    # Paypal passes:
    # "TOKEN"=>"EC%2d58984565JL8914125"
    # "SUCCESSPAGEREDIRECTREQUESTED"=>"false"
    # "TIMESTAMP"=>"2011%2d05%2d02T11%3a40%3a29Z"
    # "CORRELATIONID"=>"cda97fa324b64"
    # "ACK"=>"Success"
    # "VERSION"=>"65%2e1"
    # "BUILD"=>"1838679"
    # "INSURANCEOPTIONSELECTED"=>"false"
    # "SHIPPINGOPTIONISDEFAULT"=>"false"
    # "PAYMENTINFO_0_TRANSACTIONID"=>"9ST21297BC112684T"
    # "PAYMENTINFO_0_TRANSACTIONTYPE"=>"cart"
    # "PAYMENTINFO_0_PAYMENTTYPE"=>"instant"
    # "PAYMENTINFO_0_ORDERTIME"=>"2011%2d05%2d02T11%3a40%3a27Z"
    # "PAYMENTINFO_0_AMT"=>"2%2e50"
    # "PAYMENTINFO_0_FEEAMT"=>"0%2e40"
    # "PAYMENTINFO_0_TAXAMT"=>"0%2e00"
    # "PAYMENTINFO_0_CURRENCYCODE"=>"EUR"
    # "PAYMENTINFO_0_PAYMENTSTATUS"=>"Completed"
    # "PAYMENTINFO_0_PENDINGREASON"=>"None"
    # "PAYMENTINFO_0_REASONCODE"=>"None"
    # "PAYMENTINFO_0_PROTECTIONELIGIBILITY"=>"Ineligible"
    # "PAYMENTINFO_0_PROTECTIONELIGIBILITYTYPE"=>"None"
    # "PAYMENTINFO_0_ERRORCODE"=>"0"
    # "PAYMENTINFO_0_ACK"=>"Success"
    
    # if successful make the iou paid
    if result['ACK'] == "Success" and sprintf("%.2f", @iou.total) == sprintf("%.2f", CGI::unescape(result['PAYMENTINFO_0_AMT']))
      @status = "success"
      @iou.paid! unless @iou.paid?
      post_to_facebook(@iou)
      flash[:notice] = t("ious.confirm_payment.success")
      expire_page :controller => 'home', :action => 'index'
    end
    
    # // didn't get the money
    if result['ACK'] != "Success"
      @status = "failure"
    end 
  end
  
  def cancel
  end
  
  # POST here from paypal IPN (Instant Payment Notification)
  # "test_ipn"=>"1", "payment_type"=>"instant", "payment_date"=>"06:03:05 Aug 04, 2011 PDT", 
  # "payment_status"=>"Completed", "address_status"=>"unconfirmed", "payer_status"=>"unverified", 
  # "first_name"=>"John", "last_name"=>"Smith", "payer_email"=>"buyer_1288716842_per@me.com", 
  # "payer_id"=>"TESTBUYERID01", "address_name"=>"John Smith", "address_country"=>"United States", 
  # "address_country_code"=>"US", "address_zip"=>"95131", "address_state"=>"CA", "address_city"=>"San Jose", 
  # "address_street"=>"123, any street", "receiver_email"=>"biznez_1311682553_biz@me.com", 
  # "receiver_id"=>"TESTSELLERID1", "residence_country"=>"DE", "item_name"=>"Order 151", "item_number"=>"151", 
  # "quantity"=>"1", "mc_currency"=>"EUR", "mc_fee"=>"0.44", "mc_gross"=>"3.00", "mc_handling"=>"0.00", 
  # "mc_handling1"=>"0.00", "mc_shipping"=>"0.00", "mc_shipping1"=>"0.00", "txn_type"=>"cart", "txn_id"=>"584133", 
  # "notify_version"=>"2.4", "charset"=>"windows-1252", "verify_sign"=>"An5ns1Kso7MWUdW4ErQKJJJ4qi4-AzemepwDGEJ5XJdpr8cI5rMjPQGg"
  #
  # mc_gross=4.00, protection_eligibility=Ineligible, item_number1=, payer_id=EMP3JRVAYHREU, tax=0.00, 
  # payment_date=12:20:27 Aug 10, 2011 PDT, payment_status=Completed, charset=windows-1252, mc_shipping=0.00,
  # mc_handling=0.00, first_name=Stefan, mc_fee=0.50, notify_version=3.2, custom=, payer_status=verified, 
  # num_cart_items=1, mc_handling1=0.00, verify_sign=AS1YG6nyCACZwF5pTufLZw9LSEIGAUEu8no9ZINHdhqglwCDq-QKHuBM,
  # payer_email=stefan_lochner@web.de, mc_shipping1=0.00, txn_id=84N17487FS640994F, payment_type=instant, 
  # last_name=Lochner, item_name1=Order #1385, receiver_email=info@buddydrinks.com, payment_fee=, quantity1=1,
  # receiver_id=GXRFELVPJSNV8, txn_type=cart, mc_gross_1=4.00, mc_currency=EUR, residence_country=DE, 
  # transaction_subject=, payment_gross=, ipn_track_id=hBY.1AeJp89CunSeM5Iu.Q
  def ipn
    item_name = params['item_name'] if params.key?('item_name') #this is messing up the vouchers that are bought through paypal digital goods
    item_name = params['item_name1'] if params.key?('item_name1')
    logger.debug("!!!!! paypal params #{params}")
    if item_name
      if item_name.start_with?("Order") or item_name.start_with?("Bestellung") or item_name.start_with?("Commande") or item_name.start_with?("Ordine")
        # fixing invalid bytes from: http://po-ru.com/diary/fixing-invalid-utf-8-in-ruby-revisited/
        ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
        valid_string = ic.iconv(item_name + ' ')[0..-2]
        @id = valid_string.match('\\d+')[0]
        @iou = Iou.find(@id)
      end
    end
    @iou = @iou || nil
    if @iou.present? and params[:payment_status] == "Completed" and sprintf("%.2f", @iou.total) == sprintf("%.2f", params[:mc_gross])
      unless @iou.paid? #or params.key?('item_name')
        @iou.paid!
        post_to_facebook(@iou)
      end
      flash[:notice] = t("ious.confirm_payment.success")
      render :text => "OK", :status => 200
    else
      render :text => "ERROR", :status => 500
    end
    expire_page :controller => 'home', :action => 'index'
  end
  
  def express
    iou = Iou.find(params[:iou_id])
    amount_in_cents = iou.calculate_total.to_f * 100
    begin
      response = EXPRESS_GATEWAY.setup_purchase(amount_in_cents,
        :ip => request.remote_ip,
        :return_url => url_for(:action => 'complete', :id => iou.id),
        :cancel_return_url => url_for(:action => 'pay', :controller => "ious", :id => iou.id),
        :allow_guest_checkout => true,
        :items =>[{ :name => iou.item_name_list.to_sentence,
          :quantity => "1",
          :description => "XXXX",
          :amount => amount_in_cents
        }]
      )
    rescue Exception => e
      logger.error "Paypal error while make payment: #{e.message}"
      flash[:error] = e.message
    end
    
    if response.success?
      redirect_to EXPRESS_GATEWAY.redirect_url_for(response.token)
    else
      redirect_to :action => "pay", :controller => "ious", :id => iou.id
    end
  end

  def complete 
    iou = Iou.find(params[:id])
    amount = iou.calculate_total.to_f * 100
    begin
      purchase = EXPRESS_GATEWAY.purchase(amount,
        :ip       => request.remote_ip,
        :payer_id => iou.sender_id,
        :token    => iou.token
      )
    rescue Exception => e
        logger.error "Paypal error while make payment: #{e.message}"
        flash[:error] = e.message
    end
    unless purchase.success?
        flash[:error] = "Unfortunately an error occurred:" + purchase.message
    else
        flash[:notice] = "Thank you for your payment"
    end
    redirect_to :action => "completed", :controller => "ious", :id => iou.id
  end
  
  def change_paid_status
    iou = Iou.find(params[:id])
    if iou.present? 
      unless iou.paid? 
        iou.paid!
        post_to_facebook(iou)
        flash[:notice] = t("ious.confirm_payment.success")
      end
      Subcription.after_paypal_payment_details(iou, params[:PayerID], params[:token]) if iou.paid?
    else
      flash[:error] = "Unfortunately an error occurred"
    end
  end
  
end
