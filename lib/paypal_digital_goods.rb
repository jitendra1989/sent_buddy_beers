# Paypal Digital Goods Wrapper
# Coded by: Travis J. Todd
# Version: 0.1
# Notes: Does not include refunds or recurring payments yet.
# Inspiration from: http://www.ioncannon.net/programming/91/using-ruby-and-httparty-to-consume-web-services-the-easy-way/

require 'rubygems'
require 'httparty'

class PaypalDigitalGoods
  include HTTParty
  
  def initialize(api_user_name=nil, api_password=nil, api_signature=nil)
    @api_user_name = (Rails.env.production? or Rails.env.staging?) ? "info_api1.buddybeers.com" : "seller_1266157604_biz_api1.me.com"
    @api_password = (Rails.env.production? or Rails.env.staging?) ? "K692JVUC7DZAKTKY" : "1266157619"
    @api_signature = (Rails.env.production? or Rails.env.staging?) ? "ASZ.AzcHRZF-R3WY9HaFNgtf42CdAaTy0cu3ucPvkYw4Wf1oYjFp-fTY" : "AFcWxV21C7fd0v3bYYYRCpSSRl31Afdi6kKCYo04p.PLMuRoxO3f5LOl"
  end

  def set_express_checkout(id, amount, currency, name, description, quantity, options={})
    method_name = "SetExpressCheckout"
    puts("!!!!!!!!!!!!! #{options.inspect} #{options.has_key?("in_facebook")} !!!!!!!!!!!!!")
    puts("!!!!!!!!!!!!! #{options.has_key?(:return_uri)} #{options.has_key?("return_uri")} !!!!!!!!!!!!!")
    request_params = build_request(method_name, amount, currency, name, description, quantity, 'Sale')
    request_params.merge!({"RETURNURL" => options.has_key?("return_uri") ? options["return_uri"] : "http://#{current_site ? current_site.domain : "buddybeers.com"}#{":3000" if Rails.env.development?}/paypal/confirmation/#{id}?amt=#{amount}&cur=#{currency}&in_facebook=#{options.has_key?("in_facebook")}",
                           "CANCELURL" => options.has_key?("cancel_uri") ? options["cancel_uri"] : "http://#{current_site ? current_site.domain : "buddybeers.com"}#{":3000" if Rails.env.development?}/paypal/cancel?order_id=#{id}&in_facebook=#{options.has_key?("in_facebook")}"})
    response = make_request(request_params)
  end
  
  def do_express_checkout_payment(id, amount, currency, name, description, quantity, token, payer_id)
    method_name = "DoExpressCheckoutPayment"
    request_params = build_request(method_name, amount, currency, name, description, quantity, 'SALE')
    request_params.merge!({'TOKEN' => token, 'PAYERID' => payer_id})
    response = make_request(request_params)
  end
  
  def get_paypal_url(token)
    url = "https://www.paypal.com/incontext?token=#{token}&useraction=commit"
    unless (Rails.env.production? or Rails.env.staging?)
      url = "https://www.sandbox.paypal.com/incontext?token=#{token}&useraction=commit"
    end
    return url
  end
  
private  
  def build_request(method_name, amount, currency, name, description, quantity, payment_action)
    nvp_str = {}
    #TODO: Change to buddy beers images and colors:
    nvp_str.merge!({'PAYMENTREQUEST_0_AMT' => amount,
                    'PAYMENTREQUEST_0_PAYMENTACTION' => payment_action,
                    'PAYMENTREQUEST_0_CURRENCYCODE' => currency,
                    'L_PAYMENTREQUEST_0_NAME0' => name,
                    'L_PAYMENTREQUEST_0_DESC0' => description,
                    'L_PAYMENTREQUEST_0_AMT0' => amount,
                    'L_PAYMENTREQUEST_0_QTY0' => quantity,
                    'L_PAYMENTREQUEST_0_ITEMCATEGORY0' => 'Digital',
                    'REQCONFIRMSHIPPING' => '0',
                    'NOSHIPPING' => '1',
                    'HDRIMG' => 'https://www.paypal.com/en_US/i/logo/paypal_logo.gif',
                    'LOGOIMG' => 'https://www.paypal.com/en_US/i/logo/paypal_logo.gif',
                    'CARTBORDERCOLOR' => 'E98E04',
                    'BRANDNAME' => 'Buddy Beers',
                    'LOCALECODE' => I18n.locale.to_s.upcase})
    nvpreq = {'METHOD' => method_name, 'VERSION' => '65.1', 'USER' => @api_user_name, 'PWD' => @api_password, 'SIGNATURE' => @api_signature}.merge(nvp_str)
    return nvpreq
  end

  def make_request(request_params)
    response = parse_response(HTTParty.post("https://api-3t#{".sandbox" unless (Rails.env.production? or Rails.env.staging?)}.paypal.com/nvp", :body => request_params, :headers => {"Content-Type" => "text/html; charset=utf-8"}))
    return response
  end
  
  def parse_response(http_response)
    http_response_ar = http_response.body.split("&")
    http_parsed_response_ar = {}
    http_response_ar.each do |value|
      temp_ar = value.split("=")
      if temp_ar.size > 1
        http_parsed_response_ar.merge!({temp_ar[0] => temp_ar[1]})
      end
    end
    return http_parsed_response_ar
  end
  
  def current_site
    Thread.current[:current_site]
  end

end