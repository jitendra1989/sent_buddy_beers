require 'test_helper'

class Affiliate::BarsControllerTest < ActionController::TestCase
  fixtures :all

  # index
  context "GET to dashboard" do
    context "while logged in as affiliate" do
      setup do
        sign_in(:affiliate)
        get :index
      end

      should assign_to(:current_user)
      should respond_with(:success)
      should render_template(:index)
      should_not set_the_flash

      should "have a user that responds true to affiliate?" do
        assert assigns(:current_user).affiliate?
      end

      should "have a user that responds false to bro?" do
        assert !assigns(:current_user).bro?
      end
    end

    context "while logged in as bro" do
      setup do
        sign_in(:bro)
        get :index
      end

      should assign_to(:current_user)
      should respond_with(:success)
      should render_template(:index)
      should_not set_the_flash

      should "have a user that responds true to bro?" do
        assert assigns(:current_user).bro?
      end

      should "have a user that responds false to affiliate?" do
        assert !assigns(:current_user).affiliate?
      end
    end

    context "while logged in as customer" do
      setup do
        sign_in :customer
        get :index
      end

      should assign_to(:current_user)
      should respond_with(:redirect)
      should redirect_to("the home page"){ root_url }
      should set_the_flash.to("You do not have the correct privileges to access this page")
    end
  end

  # update
  context "PUT to update" do
    context "and logged in as affilaite" do
      setup { sign_in(:affiliate) }
      
      context "and updating the bar's information" do
        setup do
          put :update, :id => bars(:inactive_bar).id, :bar => {:url => "www.website.com"}
        end
    
        should assign_to(:bar)
        should assign_to(:current_user)
        should respond_with(:redirect)
        should redirect_to("the bar's page"){ affiliate_bar_url(assigns(:bar)) }
      
        should "have http:// automatically prepended to url" do
          assert assigns(:bar).url.starts_with?("http://")
        end
      end
      
      context "and posting values" do
        setup do
          @voucher_count = bars(:active_bar).vouchers.redeemable.size
        end
        
        context "for an incorrect voucher" do
          setup do
            put :update, :id => bars(:active_bar).id, :bar => {:vouchers_attributes => {"1" => {:id => vouchers(:valid_voucher).id, :redemption_code => "!!"}}}
          end
          
          should assign_to(:bar)
          should assign_to(:current_user)
          should respond_with(:redirect)
          should redirect_to("the bar's page"){ affiliate_bar_url(assigns(:bar)) }
          should set_the_flash.to("Your vouchers were not redeemed. Please try again.")
          
          should "have no change in redeemable vouchers" do
            assert_equal @voucher_count, bars(:active_bar).vouchers(true).redeemable.size
          end
        end
        
        context "for one correct voucher" do
          setup do
            put :update, :id => bars(:active_bar).id, :bar => {:vouchers_attributes => {"1" => {:id => vouchers(:valid_voucher).id, :redemption_code => vouchers(:valid_voucher).redemption_token}}}
          end
          
          should assign_to(:bar)
          should assign_to(:current_user)
          should respond_with(:redirect)
          should redirect_to("the bar's page"){ affiliate_bar_url(assigns(:bar)) }
          should set_the_flash.to("Vouchers Redeemed: 1")
          
          should "have a change in redeemable vouchers" do
            assert_equal 1, @voucher_count - bars(:active_bar).vouchers(true).redeemable.size
          end
        end
        
        context "for one correct and one incorrect voucher" do
          setup do
            put :update, :id => bars(:active_bar).id, :bar => {:vouchers_attributes => {"1" => {:id => vouchers(:valid_voucher).id, :redemption_code => vouchers(:valid_voucher).redemption_token}, "2" => {:id => vouchers(:valid_voucher_for_weiss).id, :redemption_code => "!!"}}}
          end
          
          should assign_to(:bar)
          should assign_to(:current_user)
          should respond_with(:redirect)
          should redirect_to("the bar's page"){ affiliate_bar_url(assigns(:bar)) }
          should set_the_flash.to("Vouchers Redeemed: 1")
          
          should "have a change in redeemable vouchers" do
            assert_equal 1, @voucher_count - bars(:active_bar).vouchers(true).redeemable.size
          end
        end
      end
    end
  end

  #show
  context "GET to :show" do
    context "and logged in as affiliate" do
      setup do
        sign_in(:affiliate)
        get :show, :id => bars(:active_bar).id
      end

      should assign_to(:bar)
      should assign_to(:current_user)
      should assign_to(:activity)
      should respond_with(:success)
      should render_template(:show)
      should_not set_the_flash
    end
  end

  #vouchers

  context "GET to vouchers" do
    context "while logged in as affiliate" do
      setup do
        @affiliate = Factory.create(:affiliate)
        @bar = Factory.create(:bar, :affiliate => @affiliate)
        Factory.create(:voucher, :bar_id => @bar.id)
        sign_in :affiliate
        get :vouchers, :id => @bar.id
      end

      should assign_to(:bar)
      should assign_to(:lists)
      should assign_to(:current_user)
      should respond_with(:success)
      should render_template(:vouchers)
      should_not set_the_flash

      should "have the same amount of vouchers as the bar" do
        assert_equal assigns(:bar).voucher_lists.valid, assigns(:lists)
      end
    end

    context "while logged in as affiliate and posting a specific price" do
      setup do
        @affiliate = Factory.create(:affiliate)
        @bar = Factory.create(:bar, :affiliate => @affiliate)
        @price = Factory.create(:price, :bar => @bar, :cents => 499)
        Factory.create(:voucher, :bar_id => @bar.id, :cents => 499)
        sign_in :affiliate
        get :vouchers, :id => @bar.id, :price => 499
      end

      should assign_to(:bar)
      should assign_to(:lists)
      should assign_to(:current_user)
      should respond_with(:success)
      should render_template(:vouchers)
      should_not set_the_flash

      should "have the same amount of vouchers as the bar" do
        assert_equal assigns(:bar).voucher_lists.valid.find_all_by_cents(499), assigns(:lists)
      end
    end

    context "while logged in as customer" do
      setup do
        sign_in :customer
        get :vouchers, :id => bars(:active_bar).id
      end

      should_not assign_to(:bar)
      should assign_to(:current_user)
      should respond_with(:redirect)
      should redirect_to("the home page"){ root_url }
      should set_the_flash.to("You do not have the correct privileges to access this page")
    end
  end

  #gallery

  context "GET to :gallery" do
    setup { @bar = Factory(:bar, :affiliate_id => users(:affiliate).id) }

    context "while logged in as affiliate" do
      setup do
        sign_in :affiliate
        get :gallery, :id => @bar.id
      end

      should assign_to(:bar)
      should assign_to(:gallery)
      should assign_to(:current_user)
      should respond_with(:success)
      should render_template(:gallery)
      should_not set_the_flash
    end

    context "while logged in as customer" do
      setup do
        sign_in :customer
        get :gallery, :id => @bar.id
      end

      should_not assign_to(:bar)
      should_not assign_to(:gallery)
      should assign_to(:current_user)
      should respond_with(:redirect)
      should redirect_to("the home page"){ root_url }
      should set_the_flash.to("You do not have the correct privileges to access this page")
    end
  end

end
