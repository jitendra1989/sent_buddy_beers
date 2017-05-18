require 'test_helper'

class VouchersControllerTest < ActionController::TestCase
  fixtures :vouchers, :users, :ious, :bars, :cities, :countries

  context "GET to :show" do
  
    # Valid, everything kosher voucher
  
    context "with token" do
      setup { get :show, :id => vouchers(:valid_voucher_to_customer).id, :token => vouchers(:valid_voucher_to_customer).token }
  
      should assign_to(:iou)
      should assign_to(:voucher)
      should_not assign_to(:qr_image)
      should_not assign_to(:current_user)
      should redirect_to("the iou page"){ iou_url(vouchers(:valid_voucher_to_customer).iou, :code => vouchers(:valid_voucher_to_customer).iou.token) }
      should_not set_the_flash
    end
  
    # Expired voucher
  
    context "with token to expired voucher" do
      setup { get :show, :id => vouchers(:expired_voucher).id, :token => vouchers(:expired_voucher).token }
  
      should assign_to(:iou)
      should assign_to(:voucher)
      should_not assign_to(:qr_image)
      should_not assign_to(:current_user)
      should redirect_to("the iou page"){ iou_url(vouchers(:expired_voucher).iou, :code => vouchers(:expired_voucher).iou.token) }
      should_not set_the_flash
    end
  
    # No token but logged in as the owner
  
    context "No token but logged in as the owner" do
      setup do
        sign_in(:customer)
        get :show, :id => vouchers(:valid_voucher_to_customer).id
      end
  
      should assign_to(:iou)
      should assign_to(:voucher)
      should assign_to(:current_user)
      should redirect_to("the iou page"){ iou_url(vouchers(:valid_voucher_to_customer).iou, :code => vouchers(:valid_voucher_to_customer).iou.token) }
      should_not set_the_flash
  
      should "make sure the voucher recipient is the current user" do
        assert_equal assigns(:current_user), assigns(:iou).recipient
      end
    end
  
    # No token but logged in as the admin
  
    context "No token but logged in as the admin" do
      setup do
        sign_in(:admin)
        get :show, :id => vouchers(:valid_voucher_to_customer).id
      end
  
      should assign_to(:iou)
      should assign_to(:voucher)
      should_not assign_to(:qr_image)
      should assign_to(:current_user)
      should redirect_to("the iou page"){ iou_url(vouchers(:valid_voucher_to_customer).iou, :code => vouchers(:valid_voucher_to_customer).iou.token) }
      should_not set_the_flash
  
      should "make sure the voucher recipient is not the current user" do
        assert_not_equal assigns(:current_user), assigns(:iou).recipient
      end
    end
  
    # No token and not logged in, should redirect
  
    context "No token and not logged in" do
      setup { get :show, :id => vouchers(:valid_voucher_to_customer).id }
  
      should assign_to(:iou)
      should assign_to(:voucher)
      should_not assign_to(:qr_image)
      should_not assign_to(:current_user)
      should set_the_flash.to("You do not have the correct privileges to access this page")
      should redirect_to("the root page"){ root_url }
    end
  
    # Incorrect Token, should redirect
  
    context "Incorrect Token" do
      setup { get :show, :id => vouchers(:valid_voucher_to_customer).id, :token => "incorrect" }
  
      should assign_to(:iou)
      should assign_to(:voucher)
      should_not assign_to(:current_user)
      should set_the_flash.to("You do not have the correct privileges to access this page")
      should redirect_to("the root page"){ root_url }
    end
  end
  
  # vouchers#check
  context "on GET to check" do
    
    context "when logged in" do
      setup do
        sign_in(Factory(:affiliate))
        get :check
      end
      
      should respond_with(:success)
      should render_with_layout("popup")
    end
    
    context "when logged out" do
      setup { get :check }
      should respond_with(:redirect)
    end
  end
  
  # vouchers#redeem
  context "on POST to redeem" do
    setup do
      @bar = Factory(:bar)
      @price = Factory(:price, :bar => @bar)
      @iou = Factory(:iou, :price => @price)
      @iou.paid!
      @voucher = @iou.vouchers.first
      assert @voucher.present?
    end 
    
    # As Admin
    context "when logged in as an admin" do
      setup do
        @admin = Factory(:admin)
        sign_in(@admin)
      end
      
      context "and posting a correct voucher code" do
        setup do
          post :redeem, :code => @voucher.coupon
        end
        
        should respond_with(:success)
        should assign_to(:current_user)
        should assign_to(:status)
        should assign_to(:voucher)
        should render_template(:check)
        should render_with_layout("popup")
        
        should "assign to same voucher as passed in" do
          assert_equal @voucher, assigns(:voucher)
        end
        
        should "redeem voucher" do
          assert @voucher.reload.redeemed, @admin.redeemable_vouchers.include?(@voucher).to_s
        end
        
        should "have a status hash" do
          assert assigns(:status).is_a?(Hash)
        end
        
        should "have a success status" do
          assert_equal "<span class=\"price\">#{@voucher.amount} #{@voucher.iou.price_name}</span> Voucher for #{@voucher.bar.name} redeemed!", assigns(:status)[:success], assigns(:status)
        end
      end
      
      context "and posting no voucher code" do
        setup do
          post :redeem, :code => ""
        end
        
        should respond_with(:success)
        should assign_to(:current_user)
        should assign_to(:status)
        should_not assign_to(:voucher)
        should render_with_layout("popup")
        
        should "not redeem not voucher" do
          assert !@voucher.redeemed
        end
        
        should "have a status hash" do
          assert assigns(:status).is_a?(Hash)
        end
        
        should "have a error status" do
          assert_equal assigns(:status)[:error], "You did not enter a voucher number. Please try again."
        end
      end
      
      context "and not having any redeemable vouchers" do
        setup do
          @admin.redeemable_vouchers.each do |v|
            v.update_attributes(:redeemed => true, :redeemed_at => DateTime.now)
          end
          post :redeem, :code => @voucher.coupon
        end
        
        should respond_with(:success)
        should assign_to(:current_user)
        should assign_to(:status)
        should_not assign_to(:voucher)
        should render_with_layout("popup")
        
        should "have a status hash" do
          assert assigns(:status).is_a?(Hash)
        end
        
        should "have a error status" do
          assert_equal assigns(:status)[:error], "All your vouchers have already been redeemed."
        end
      end
      
      context "and posting incorrect voucher code" do
        setup do
          post :redeem, :code => "ABCDEFG"
        end
        
        should respond_with(:success)
        should assign_to(:current_user)
        should assign_to(:status)
        should_not assign_to(:voucher)
        should render_with_layout("popup")
        
        should "not redeem not voucher" do
          assert !@voucher.redeemed
        end
        
        should "have a status hash" do
          assert assigns(:status).is_a?(Hash)
        end
        
        should "have a error status" do
          assert_equal assigns(:status)[:error], "This voucher was not found or was already redeemed."
        end
      end
    end
    
    # As Affiliate
    context "when logged in as an affiliate" do
      setup do
        @affiliate = Factory(:affiliate)
        @bar.affiliate = @affiliate
        @bar.save
        sign_in(@affiliate)
      end
      
      context "and posting a correct voucher code" do
        setup do
          post :redeem, :code => @voucher.coupon
        end
        
        should respond_with(:success)
        should assign_to(:current_user)
        should assign_to(:status)
        should assign_to(:voucher)
        
        should "assign to same voucher as passed in" do
          assert_equal @voucher, assigns(:voucher)
        end
        
        should "redeem voucher" do
          assert @voucher.reload.redeemed
        end
        
        should "have a status hash" do
          assert assigns(:status).is_a?(Hash)
        end
        
        should "have a success status" do
          assert_equal assigns(:status)[:success], "<span class=\"price\">#{@voucher.amount} #{@voucher.iou.price_name}</span> Voucher for #{@voucher.bar.name} redeemed!"
        end
      end
      
      context "and posting no voucher code" do
        setup do
          post :redeem, :code => ""
        end
        
        should respond_with(:success)
        should assign_to(:current_user)
        should assign_to(:status)
        should_not assign_to(:voucher)
        should render_with_layout("popup")
        
        should "not redeem not voucher" do
          assert !@voucher.redeemed
        end
        
        should "have a status hash" do
          assert assigns(:status).is_a?(Hash)
        end
        
        should "have a error status" do
          assert_equal assigns(:status)[:error], "You did not enter a voucher number. Please try again."
        end
      end
      
      context "and not having any redeemable vouchers" do
        setup do
          @affiliate.redeemable_vouchers.each do |v|
            v.update_attributes(:redeemed => true, :redeemed_at => DateTime.now)
          end
          post :redeem, :code => @voucher.coupon
        end
        
        should respond_with(:success)
        should assign_to(:current_user)
        should assign_to(:status)
        should_not assign_to(:voucher)
        should render_with_layout("popup")
        
        should "have a status hash" do
          assert assigns(:status).is_a?(Hash)
        end
        
        should "have a error status" do
          assert_equal assigns(:status)[:error], "All your vouchers have already been redeemed."
        end
      end
      
      context "and posting incorrect voucher code" do
        setup do
          post :redeem, :code => "ABCDEFG"
        end
        
        should respond_with(:success)
        should assign_to(:current_user)
        should assign_to(:status)
        should_not assign_to(:voucher)
        should render_with_layout("popup")
        
        should "not redeem not voucher" do
          assert !@voucher.redeemed
        end
        
        should "have a status hash" do
          assert assigns(:status).is_a?(Hash)
        end
        
        should "have a error status" do
          assert_equal assigns(:status)[:error], "This voucher was not found or was already redeemed."
        end
      end
    end
    
    # As Bro
    context "when logged in as a bro" do
      setup do
        @bro = Factory(:bro)
        @bar.bro = @bro
        @bar.save
        sign_in(@bro)
      end
      
      context "and posting a correct voucher code" do
        setup { post :redeem, :code => @voucher.coupon }
        
        should respond_with(:success)
        should assign_to(:current_user)
        should assign_to(:status)
        should assign_to(:voucher)
        
        should "assign to same voucher as passed in" do
          assert_equal @voucher, assigns(:voucher)
        end
        
        should "redeem voucher" do
          assert @voucher.reload.redeemed
        end
        
        should "have a status hash" do
          assert assigns(:status).is_a?(Hash)
        end
        
        should "have a success status" do
          assert_equal assigns(:status)[:success], "<span class=\"price\">#{@voucher.amount} #{@voucher.iou.price_name}</span> Voucher for #{@voucher.bar.name} redeemed!"
        end
      end
    
      context "and posting no voucher code" do
        setup do
          post :redeem, :code => ""
        end
        
        should respond_with(:success)
        should assign_to(:current_user)
        should assign_to(:status)
        should_not assign_to(:voucher)
        should render_with_layout("popup")
        
        should "not redeem not voucher" do
          assert !@voucher.redeemed
        end
        
        should "have a status hash" do
          assert assigns(:status).is_a?(Hash)
        end
        
        should "have a error status" do
          assert_equal assigns(:status)[:error], "You did not enter a voucher number. Please try again."
        end
      end
      
      context "and not having any redeemable vouchers" do
        setup do
          @bro.redeemable_vouchers.each do |v|
            v.update_attributes(:redeemed => true, :redeemed_at => DateTime.now)
          end
          post :redeem, :code => @voucher.coupon
        end
        
        should respond_with(:success)
        should assign_to(:current_user)
        should assign_to(:status)
        should_not assign_to(:voucher)
        should render_with_layout("popup")
        
        should "have a status hash" do
          assert assigns(:status).is_a?(Hash)
        end
        
        should "have a error status" do
          assert_equal assigns(:status)[:error], "All your vouchers have already been redeemed."
        end
      end
      
      context "and posting incorrect voucher code" do
        setup do
          post :redeem, :code => "ABCDEFG"
        end
        
        should respond_with(:success)
        should assign_to(:current_user)
        should assign_to(:status)
        should_not assign_to(:voucher)
        should render_with_layout("popup")
        
        should "not redeem not voucher" do
          assert !@voucher.redeemed
        end
        
        should "have a status hash" do
          assert assigns(:status).is_a?(Hash)
        end
        
        should "have a error status" do
          assert_equal assigns(:status)[:error], "This voucher was not found or was already redeemed."
        end
      end
    end
    
    # As Employee
    context "when logged in as a employee" do
      setup do
        @employee = Factory(:customer)
        Factory(:employment, :bar => @bar, :user => @employee)
        sign_in(@employee)
      end
      
      context "and posting a correct voucher code" do
        setup { post :redeem, :code => @voucher.coupon }
        
        should respond_with(:success)
        should assign_to(:current_user)
        should assign_to(:status)
        should assign_to(:voucher)
        
        should "assign to same voucher as passed in" do
          assert_equal @voucher, assigns(:voucher)
        end
        
        should "redeem voucher" do
          assert @voucher.reload.redeemed
        end
        
        should "have a status hash" do
          assert assigns(:status).is_a?(Hash)
        end
        
        should "have a success status" do
          assert_equal assigns(:status)[:success], "<span class=\"price\">#{@voucher.amount} #{@voucher.iou.price_name}</span> Voucher for #{@voucher.bar.name} redeemed!"
        end
      end
      
      context "and posting no voucher code" do
        setup do
          post :redeem, :code => ""
        end
        
        should respond_with(:success)
        should assign_to(:current_user)
        should assign_to(:status)
        should_not assign_to(:voucher)
        should render_with_layout("popup")
        
        should "not redeem not voucher" do
          assert !@voucher.redeemed
        end
        
        should "have a status hash" do
          assert assigns(:status).is_a?(Hash)
        end
        
        should "have a error status" do
          assert_equal assigns(:status)[:error], "You did not enter a voucher number. Please try again."
        end
      end
      
      context "and not having any redeemable vouchers" do
        setup do
          @employee.redeemable_vouchers.each do |v|
            v.update_attributes(:redeemed => true, :redeemed_at => DateTime.now)
          end
          post :redeem, :code => @voucher.coupon
        end
        
        should respond_with(:success)
        should assign_to(:current_user)
        should assign_to(:status)
        should_not assign_to(:voucher)
        should render_with_layout("popup")
        
        should "have a status hash" do
          assert assigns(:status).is_a?(Hash)
        end
        
        should "have a error status" do
          assert_equal assigns(:status)[:error], "All your vouchers have already been redeemed."
        end
      end
      
      context "and posting incorrect voucher code" do
        setup do
          post :redeem, :code => "ABCDEFG"
        end
        
        should respond_with(:success)
        should assign_to(:current_user)
        should assign_to(:status)
        should_not assign_to(:voucher)
        should render_with_layout("popup")
        
        should "not redeem not voucher" do
          assert !@voucher.redeemed
        end
        
        should "have a status hash" do
          assert assigns(:status).is_a?(Hash)
        end
        
        should "have a error status" do
          assert_equal assigns(:status)[:error], "This voucher was not found or was already redeemed."
        end
      end
    end
    
    # As Customer
    context "when logged in as a employee" do
      setup do
        @customer = Factory(:customer)
        sign_in(@customer)
      end
      
      context "and posting correct voucher code" do
        setup do
          post :redeem, :code => @voucher.coupon
        end
        
        should respond_with(:success)
        should assign_to(:current_user)
        should assign_to(:status)
        should_not assign_to(:voucher)
        should render_with_layout("popup")
        
        should "not redeem not voucher" do
          assert !@voucher.redeemed
        end
        
        should "have a status hash" do
          assert assigns(:status).is_a?(Hash)
        end
        
        should "have a error status" do
          assert_equal assigns(:status)[:error], "Sorry, you do not have permission to redeem vouchers."
        end
      end
    end
    
    context "when logged out" do
      setup { post :redeem, :code => "ABCDEFG" }
      should respond_with(:redirect)
    end
  end
  
end
