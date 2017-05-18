require 'test_helper'

class SmsControllerTest < ActionController::TestCase
  
  # POST to CREATE
  context "on POST to CREATE" do
    context "with a valid tropo post" do
      setup do
        @voucher = Factory(:voucher, :iou => Factory(:iou, :recipient_phone => "19043027233"))
        post :create, :session => {
          "id" => "f9e1e0fde9ade9591a4a4c68261ba5ee", 
          "accountId" =>"66173", 
          "timestamp" => "2011-05-04 13:00:13 UTC", 
          "userType" => "NONE", 
          "initialText" => nil,
          "callId" => nil, 
          "parameters" => {
            "numberToDial" => @voucher.iou.recipient_phone, 
            "format" => "form", 
            "msg" => "buy another round",
            "iou_id" => @voucher.iou.id
            }
          }
      end
    
      should assign_to(:iou)
      should assign_to(:to)
      should assign_to(:msg)
      should assign_to(:sms)
      should respond_with(:success)
    
      should "have the same iou as passed in" do
        assert_equal assigns(:iou), @voucher.iou
      end
    
      should "mark the voucher as sms notified" do
        assert_not_nil assigns(:iou).sms_notified_at
      end
    
      should "have the same number to dial as passed in" do
        assert_equal assigns(:to), "+#{@voucher.iou.recipient_phone}"
      end
    
      should "have the same message as passed in" do
        assert_equal assigns(:msg), "buy another round"
      end
    
      should "render json with correct Tropo root" do
        #"tropo"=>[{"message"=>{"to"=>"+4917623581384", "network"=>"SMS", "say"=>[{"value"=>"buy another round"}]}}]
        json = JSON.parse(response.body)
        #assert false, json.inspect
        assert json.keys.include?("tropo")
        assert json["tropo"].is_a?(Array)
        assert json["tropo"][0]["message"].is_a?(Hash)
        assert_equal json["tropo"][0]["message"]["to"], assigns(:to)
        assert_equal json["tropo"][0]["message"]["network"], "SMS"
        # assert_equal json["tropo"][0]["message"]["callerID"], "13016837843"
        assert json["tropo"][0]["message"]["say"].is_a?(Array)
        assert_equal json["tropo"][0]["message"]["say"][0]["value"], assigns(:msg)
      end
    end
    context "with a missing voucher id" do
      setup do
        @voucher = Factory(:voucher, :iou => Factory(:iou, :recipient_phone => "19043027233"))
        post :create, :session => {
          "id" => "f9e1e0fde9ade9591a4a4c68261ba5ee", 
          "accountId" =>"66173", 
          "timestamp" => "2011-05-04 13:00:13 UTC", 
          "userType" => "NONE", 
          "initialText" => nil,
          "callId" => nil, 
          "parameters" => {
            "numberToDial" => @voucher.iou.recipient_phone, 
            "format" => "form", 
            "msg" => "buy another round"
            }
          }
      end
      
      should assign_to(:to)
      should assign_to(:msg)
      should assign_to(:sms)
      should respond_with(:success)
    
      should "have a nil iou" do
        assert_nil assigns(:iou)
      end
    
      should "not mark the voucher as sms notified" do
        assert_nil @voucher.iou.sms_notified_at
      end
    
      should "have the same number to dial as passed in" do
        assert_equal assigns(:to), "+#{@voucher.iou.recipient_phone}"
      end
    
      should "have the same message as passed in" do
        assert_equal assigns(:msg), "buy another round"
      end
    
      should "render json with correct Tropo root" do
        #"tropo"=>[{"message"=>{"to"=>"+4917623581384", "network"=>"SMS", "say"=>[{"value"=>"buy another round"}]}}]
        json = JSON.parse(response.body)
        #assert false, json.inspect
        assert json.keys.include?("tropo")
        assert json["tropo"].is_a?(Array)
        assert json["tropo"][0]["message"].is_a?(Hash)
        assert_equal json["tropo"][0]["message"]["to"], assigns(:to)
        assert_equal json["tropo"][0]["message"]["network"], "SMS"
        # assert_equal json["tropo"][0]["message"]["callerID"], "13016837843"
        assert json["tropo"][0]["message"]["say"].is_a?(Array)
        assert_equal json["tropo"][0]["message"]["say"][0]["value"], assigns(:msg)
      end
    end
    context "with a missing phone number" do
      setup do
        @voucher = Factory(:voucher, :iou => Factory(:iou, :recipient_phone => "19043027233"))
        @email_count = ActionMailer::Base.deliveries.length
        post :create, :session => {
          "id" => "f9e1e0fde9ade9591a4a4c68261ba5ee", 
          "accountId" =>"66173", 
          "timestamp" => "2011-05-04 13:00:13 UTC", 
          "userType" => "NONE", 
          "initialText" => nil,
          "callId" => nil, 
          "parameters" => { 
            "format" => "form", 
            "msg" => "buy another round",
            "iou_id" => @voucher.iou.id
            }
          }
      end
      
      should assign_to(:iou)
      should assign_to(:to)
      should assign_to(:msg)
      should assign_to(:sms)
      should respond_with(:success)
    
      should "have the same iou as passed in" do
        assert_equal assigns(:iou), @voucher.iou
      end
    
      should "mark the voucher as sms notified" do
        assert_not_nil assigns(:iou).sms_notified_at
      end
    
      should "not have an error in the to valiable" do
        assert_equal assigns(:to), "+#{@voucher.iou.recipient_phone}"
      end
    
      should "not have the error message" do
        assert_equal assigns(:msg), "buy another round"
      end
    
      should "render json with correct Tropo root" do
        #"tropo"=>[{"message"=>{"to"=>"+4917623581384", "network"=>"SMS", "say"=>[{"value"=>"buy another round"}]}}]
        json = JSON.parse(response.body)
        #assert false, json.inspect
        assert json.keys.include?("tropo")
        assert json["tropo"].is_a?(Array)
        assert json["tropo"][0]["message"].is_a?(Hash)
        assert_equal json["tropo"][0]["message"]["to"], assigns(:to)
        assert_equal json["tropo"][0]["message"]["network"], "SMS"
        # assert_equal json["tropo"][0]["message"]["callerID"], "13016837843"
        assert json["tropo"][0]["message"]["say"].is_a?(Array)
        assert_equal json["tropo"][0]["message"]["say"][0]["value"], assigns(:msg)
      end
      
      should "not send an email" do
        assert_equal 0, ActionMailer::Base.deliveries.length - @email_count
      end
    end
  end
  
end
