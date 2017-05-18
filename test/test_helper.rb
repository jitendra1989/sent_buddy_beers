# -*- coding: utf-8 -*-
ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

require "shoulda"
require "mocha"

# Requires supporting files in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

class ActiveSupport::TestCase
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false

  setup do
    stub_attachments!
    stub_internets!
    stub_geocoding!
    reset_pathset_cache!
    setup_default_site
  end

  def stub_attachments!
    Paperclip::Attachment.any_instance.stubs(:post_process).returns(true)
    Photo.any_instance.stubs(:save_attached_files).returns(true)
    Photo.any_instance.stubs(:delete_attached_files).returns(true)
  end

  def stub_internets!
    FakeWeb.allow_net_connect = false
    FakeWeb.register_uri(:post, "https://api-3t.sandbox.paypal.com/nvp", :body => "TOKEN=EC%2d58984565JL8914125&SUCCESSPAGEREDIRECTREQUESTED=false&TIMESTAMP=2011%2d05%2d02T11%3a40%3a29Z&CORRELATIONID=cda97fa324b64&ACK=Success&VERSION=65%2e1&BUILD=1838679&INSURANCEOPTIONSELECTED=false&SHIPPINGOPTIONISDEFAULT=false&PAYMENTINFO_0_TRANSACTIONID=9ST21297BC112684T&PAYMENTINFO_0_TRANSACTIONTYPE=cart&PAYMENTINFO_0_PAYMENTTYPE=instant&PAYMENTINFO_0_ORDERTIME=2011%2d05%2d02T11%3a40%3a27Z&PAYMENTINFO_0_AMT=3%2e00&PAYMENTINFO_0_FEEAMT=0%2e40&PAYMENTINFO_0_TAXAMT=0%2e00&PAYMENTINFO_0_CURRENCYCODE=EUR&PAYMENTINFO_0_PAYMENTSTATUS=Completed&PAYMENTINFO_0_PENDINGREASON=None&PAYMENTINFO_0_REASONCODE=None&PAYMENTINFO_0_PROTECTIONELIGIBILITY=Ineligible&PAYMENTINFO_0_PROTECTIONELIGIBILITYTYPE=None&PAYMENTINFO_0_ERRORCODE=0&PAYMENTINFO_0_ACK=Success")
    FakeWeb.register_uri(:post, "https://api.tropo.com/1.0/sessions", :body => "OK")
    FakeWeb.register_uri(:get, "https://graph.facebook.com/me/permissions?access_token=166942940015970%257C2.sa", :body => {"data" => [{"email" => 1, "publish_stream" => 1, "type" => "permissions"}] }.to_json)
    FakeWeb.register_uri(:post, "https://api.twitter.com/1/statuses/update.json", :body => {"coordinates" => nil, "created_at" => DateTime.now(), "truncated" => false,"favorited" => false,"id_str" => "84315710834212866","entities" => {"urls" => [],"hashtags" => [{"text" => "peterfalk","indices" => [35,45]}],"user_mentions" => []},"in_reply_to_user_id_str" => nil,"contributors" => nil,"text" => "Maybe he'll finally find his keys. #peterfalk","retweet_count" => 0,"id" => 84315710834212866,"in_reply_to_status_id_str" => nil,"geo" => nil,"retweeted" => false,"in_reply_to_user_id" => nil,"source" => "<a href=\"http://sites.google.com/site/yorufukurou/\" rel=\"nofollow\">YoruFukurou</a>","in_reply_to_screen_name" => nil,"user" => {"id_str" => "819797","id" => 819797},"place" => nil,"in_reply_to_status_id" => nil}.to_json)
    FakeWeb.register_uri(:post, "https://us1.api.mailchimp.com/1.3/?method=listSubscribe", :body => "true")
  end

  def stub_geocoding!
    geoloc = GeoKit::GeoLoc.new(:lat => 52.53002, :lng => 13.3831)
    geoloc.success = true
    GeoKit::Geocoders::MultiGeocoder.stubs(:geocode).returns(geoloc)
  end

  def reset_pathset_cache!
    # CustomViewPaths.class_variable_set("@@pathsets", nil)
    CustomViewPaths.class_eval {class_variable_set :@@pathsets , nil}
  end

  def setup_default_site
    Thread.current[:current_site] = Factory(:default_site)
  end
end

class ActionController::TestCase
  include Devise::TestHelpers
   
  # Hack for Devise controllers test
  def setup
    request.env["devise.mapping"] = Devise.mappings[:user]
  end

  def sign_in(user)
    super(user.is_a?(Symbol) ? users(user) : user)
  end
  
  def assert_response_equals(v)
    assert_equal v.to_s, @response.body, "Expected response body to be #{v.inspect}, instead it was #{@response.body}"
  end
  
  def assert_response_contains(v)
    assert @response.body.include?(v.to_s), "Expected response body to contain #{v.inspect}, instead it was #{@response.body}"
  end
end

class Test::Unit::TestCase
  def self.should_have_attached_file(attachment)
    klass = self.name.gsub(/Test$/, '').constantize

    context "To support a paperclip attachment named #{attachment}, #{klass}" do
      should_have_db_column("#{attachment}_file_name",    :type => :string)
      should_have_db_column("#{attachment}_content_type", :type => :string)
      should_have_db_column("#{attachment}_file_size",    :type => :integer)
    end

    should "have a paperclip attachment named ##{attachment}" do
      assert klass.new.respond_to?(attachment.to_sym), 
             "@#{klass.name.underscore} doesn't have a paperclip field named #{attachment}"
      assert_equal Paperclip::Attachment, klass.new.send(attachment.to_sym).class
    end
  end
end