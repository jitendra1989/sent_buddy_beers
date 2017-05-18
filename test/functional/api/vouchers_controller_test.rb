require 'test_helper'

class Api::VouchersControllerTest < ActionController::TestCase

  # GET to received
  # context "on GET to received" do
  #     setup do
  #       @user = Factory(:user)
  #       @user.confirm!
  #     end
    
   #  context "with vouchers" do
   #     setup do
   #       @iou = Factory(:iou, :sender_id => @user.id, :recipient_id => @user.id)
   #       @iou.paid!
   #       get :received, :auth_token => @user.authentication_token
   #     end
   #   
   #     should assign_to(:vouchers)
   #     should assign_to(:user)
   #     should respond_with(:success)
   #     should respond_with_content_type('application/json')
   #     should_not render_with_layout
   #   
   #     should "render the correct json" do
   #       assert_response_contains("true")
   #       assert_response_contains("vouchers")
   #       assert_response_contains("total_pages")
   #       assert_response_contains("current_page")
   #     end
   #   end
   #   
   #   context "with o vouchers" do
   #     setup do
   #       get :received, :auth_token => @user.authentication_token
   #     end
   #   
   #     should_not assign_to(:vouchers)
   #     should assign_to(:user)
   #     should respond_with(:success)
   #     should respond_with_content_type('application/json')
   #     should_not render_with_layout
   #   
   #     should "render the correct json" do
   #       assert_response_contains("false")
   #       assert_response_contains("errors")
   #     end
   #   end
   # end
   # 
   # # GET to sent
   # context "on GET to sent" do
   #   setup do
   #     @user = Factory(:user)
   #     @user.confirm!
   #   end
   #   
   #   context "with vouchers" do
   #     setup do
   #       @iou = Factory(:iou, :sender_id => @user.id, :recipient_id => @user.id)
   #       @iou.paid!
   #       get :sent, :auth_token => @user.authentication_token
   #     end
   #   
   #     should assign_to(:vouchers)
   #     should assign_to(:user)
   #     should respond_with(:success)
   #     should respond_with_content_type('application/json')
   #     should_not render_with_layout
   #   
   #     should "render the correct json" do
   #       assert_response_contains("true")
   #       assert_response_contains("vouchers")
   #       assert_response_contains("total_pages")
   #       assert_response_contains("current_page")
   #     end
   #   end
   #   
   #   context "with o vouchers" do
   #     setup do
   #       get :sent, :auth_token => @user.authentication_token
   #     end
   #   
   #     should_not assign_to(:vouchers)
   #     should assign_to(:user)
   #     should respond_with(:success)
   #     should respond_with_content_type('application/json')
   #     should_not render_with_layout
   #   
   #     should "render the correct json" do
   #       assert_response_contains("false")
   #       assert_response_contains("errors")
   #     end
   #   end
   # end
   # 
   # # GET to recent
   # context "on GET to recent" do
   #   setup do
   #     @user = Factory(:user)
   #     @user.confirm!
   #   end
   #   
   #   context "with vouchers" do
   #     setup do
   #       @iou = Factory(:iou, :sender_id => @user.id, :recipient_id => @user.id)
   #       @iou.paid!
   #       get :recent, :auth_token => @user.authentication_token
   #     end
   #   
   #     should assign_to(:ious)
   #     should assign_to(:user)
   #     should respond_with(:success)
   #     should respond_with_content_type('application/json')
   #     should_not render_with_layout
   #   
   #     should "render the correct json" do
   #       assert_response_contains("true")
   #       assert_response_contains("vouchers")
   #       assert_response_contains("total_pages")
   #       assert_response_contains("current_page")
   #     end
   #   end
   #   
   #   context "with no vouchers" do
   #     setup do
   #       get :recent, :auth_token => @user.authentication_token
   #     end
   #   
   #     should_not assign_to(:ious)
   #     should assign_to(:user)
   #     should respond_with(:success)
   #     should respond_with_content_type('application/json')
   #     should_not render_with_layout
   #   
   #     should "render the correct json" do
   #       assert_response_contains("false")
   #       assert_response_contains("errors")
   #     end
   #   end
   # end
   # 
   # #POST to redeem
   # context "on POST to redeem" do
   #   
   #   setup do
   #     @user = Factory(:user)
   #     @user.confirm!
   #   end
   #   
   #   context "with no code" do
   #     setup { post :redeem, :auth_token => @user.authentication_token }
   #     
   #     should_not assign_to(:voucher)
   #     should assign_to(:user)
   #     should respond_with(:success)
   #     should respond_with_content_type('application/json')
   #     should_not render_with_layout
   #   
   #     should "render the correct json" do
   #       assert_response_contains("false")
   #       assert_response_contains("errors")
   #     end
   #   end
   #   
   #   context "with no redeemable vouchers" do
   #     setup { post :redeem, :auth_token => @user.authentication_token, :code => "123456" }
   #     
   #     should_not assign_to(:voucher)
   #     should assign_to(:user)
   #     should respond_with(:success)
   #     should respond_with_content_type('application/json')
   #     should_not render_with_layout
   #   
   #     should "render the correct json" do
   #       assert_response_contains("false")
   #       assert_response_contains("errors")
   #     end
   #   end
   #     
   #   context "with vouchers" do
   #     setup do
   #       @iou = Factory(:iou, :sender_id => @user.id, :recipient_id => @user.id)
   #       @iou.paid!
   #     end
   #     
   #     context "but passing the incorrect code" do
   #       setup { post :redeem, :auth_token => @user.authentication_token, :code => "123456" }
   #      
   #       should_not assign_to(:voucher)
   #       should assign_to(:user)
   #       should respond_with(:success)
   #       should respond_with_content_type('application/json')
   #       should_not render_with_layout
   #   
   #       should "render the correct json" do
   #         assert_response_contains("false")
   #         assert_response_contains("errors")
   #       end
   #     end
   #     
   #     context "and passing the correct code" do
   #       setup { post :redeem, :auth_token => @user.authentication_token, :code => @iou.vouchers.first.coupon }
   #      
   #       should assign_to(:voucher)
   #       should assign_to(:user)
   #       should respond_with(:success)
   #       should respond_with_content_type('application/json')
   #       should_not render_with_layout
   #   
   #       should "render the correct json" do
   #         assert_response_contains("true")
   #         assert_response_contains("voucher")
   #       end
   #       
   #       should "be redeemed" do
   #         assert @iou.vouchers.first.reload.redeemed?
   #       end
   #     end 
   #     
   #     context "that are expired" do
   #       setup do
   #         @iou.expire! 
   #         post :redeem, :auth_token => @user.authentication_token, :code => @iou.vouchers.first.coupon
   #       end
   #      
   #       should_not assign_to(:voucher)
   #       should assign_to(:user)
   #       should respond_with(:success)
   #       should respond_with_content_type('application/json')
   #       should_not render_with_layout
   #   
   #       should "render the correct json" do
   #         assert_response_contains("false")
   #         assert_response_contains("errors")
   #       end
   #     end 
   #     
   #     context "and logged in as an admin" do
   #       setup do
   #         @admin = Factory(:admin)
   #         @admin.confirm!
   #         post :redeem, :auth_token => @admin.authentication_token, :code => @iou.vouchers.first.coupon
   #       end
   #       
   #       should assign_to(:voucher)
   #       should assign_to(:user)
   #       should respond_with(:success)
   #       should respond_with_content_type('application/json')
   #       should_not render_with_layout
   #   
   #       should "render the correct json" do
   #         assert_response_contains("true")
   #         assert_response_contains("voucher")
   #       end
   #       
   #       should "be redeemed" do
   #         assert @iou.vouchers.first.reload.redeemed?
   #       end
   #     end
   #     
   #     context "and logged in as an affiliate" do
   #       setup do
   #         @affiliate = Factory(:affiliate)
   #         @affiliate.confirm!
   #         Bar.find(@iou.bar_id).update_attribute(:affiliate_id, @affiliate.id)
   #         post :redeem, :auth_token => @affiliate.authentication_token, :code => @iou.vouchers.first.coupon
   #       end
   #       
   #       should assign_to(:voucher)
   #       should assign_to(:user)
   #       should respond_with(:success)
   #       should respond_with_content_type('application/json')
   #       should_not render_with_layout
   #   
   #       should "render the correct json" do
   #         assert_response_contains("true")
   #         assert_response_contains("voucher")
   #       end
   #       
   #       should "be redeemed" do
   #         assert @iou.vouchers.first.reload.redeemed?
   #       end
   #     end
   #     
   #     context "and logged in as a site admin" do
   #       setup do
   #         @sadmin = Factory(:site_admin)
   #         @sadmin.confirm!
   #         Bar.find(@iou.bar_id).sites << Site.find(@iou.site_id)
   #         @sadmin.sites << Site.find(@iou.site_id)
   #         post :redeem, :auth_token => @sadmin.authentication_token, :code => @iou.vouchers.first.coupon
   #       end
   #       
   #       should assign_to(:voucher)
   #       should assign_to(:user)
   #       should respond_with(:success)
   #       should respond_with_content_type('application/json')
   #       should_not render_with_layout
   #   
   #       should "render the correct json" do
   #         assert_response_contains("true")
   #         assert_response_contains("voucher")
   #       end
   #       
   #       should "be redeemed" do
   #         assert @iou.vouchers.first.reload.redeemed?
   #       end
   #     end
   #     
   #     context "and logged in as a employee" do
   #       setup do
   #         @employee = Factory(:user)
   #         @employee.confirm!
   #         Factory(:employment, :user_id => @employee.id, :bar_id => @iou.bar_id)
   #         post :redeem, :auth_token => @employee.authentication_token, :code => @iou.vouchers.first.coupon
   #       end
   #       
   #       should assign_to(:voucher)
   #       should assign_to(:user)
   #       should respond_with(:success)
   #       should respond_with_content_type('application/json')
   #       should_not render_with_layout
   #   
   #       should "render the correct json" do
   #         assert_response_contains("true")
   #         assert_response_contains("voucher")
   #       end
   #       
   #       should "be redeemed" do
   #         assert @iou.vouchers.first.reload.redeemed?
   #       end
   #     end
   #   end
   # end


  # GET to redeemed
  context "on GET to redeemed" do
    setup do
      @user = Factory(:user)
      @user.confirm!
    end
    
    context "with redeemed vouchers" do
      setup do
        4.times do
          @iou = Factory(:iou, :sender_id => @user.id, :recipient_id => @user.id)
          @iou.paid!
        end
        @user.reload.vouchers(true).first(2).each do |voucher|
          voucher.update_attributes(:redeemed => true, :redeemed_at => DateTime.now())
        end
        get :redeemed, :version => "v2", :auth_token => @user.authentication_token
      end
    
      should assign_to(:vouchers)
      should assign_to(:user)
      should respond_with(:success)
      should respond_with_content_type('application/json')
      should_not render_with_layout
    
      should "have two vouchers" do
        assert_equal 2, assigns(:vouchers).length,  @user.vouchers(true).inspect
      end
    
      should "render the correct json" do
        assert_response_contains("true")
        assert_response_contains("vouchers")
        assert_response_contains("total_pages")
        assert_response_contains("current_page")
      end
    end
    
    context "with redeemed vouchers and redeemd_since parameter" do
      setup do
        4.times do
          @iou = Factory(:iou, :sender_id => @user.id, :recipient_id => @user.id)
          @iou.paid!
        end
        vouchers = @user.reload.vouchers(true)
        vouchers.first(2).each do |voucher|
          voucher.update_attributes(:redeemed => true, :redeemed_at => 1.day.ago.to_date)
        end
        vouchers.last(2).each do |voucher|
          voucher.update_attributes(:redeemed => true, :redeemed_at => 20.days.ago.to_date)
        end
        get :redeemed, :version => "v2", :auth_token => @user.authentication_token, :redeemed_since => 2.days.ago.to_date
      end
    
      should assign_to(:vouchers)
      should assign_to(:user)
      should respond_with(:success)
      should respond_with_content_type('application/json')
      should_not render_with_layout
      
      should "have two vouchers" do
        assert_equal 2, assigns(:vouchers).length, @user.vouchers(true).inspect
      end
    
      should "render the correct json" do
        assert_response_contains("true")
        assert_response_contains("vouchers")
        assert_response_contains("total_pages")
        assert_response_contains("current_page")
      end
    end
    
    context "with no vouchers" do
      setup do
        get :redeemed, :version => "v2", :auth_token => @user.authentication_token
      end
    
      should_not assign_to(:vouchers)
      should assign_to(:user)
      should respond_with(:success)
      should respond_with_content_type('application/json')
      should_not render_with_layout
    
      should "render the correct json" do
        assert_response_contains("false")
        assert_response_contains("errors")
      end
    end
  end

end
