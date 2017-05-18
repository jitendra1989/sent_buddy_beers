require 'test_helper'

class Admin::BarsControllerTest < ActionController::TestCase
  fixtures :all
  
  setup do
    bars(:active_bar).save
  end
  
  #index
  context "GET to index" do
    context "while logged in as admin" do
      setup do
        sign_in :admin
        get :index
      end

      should_not assign_to(:bar)
      should assign_to(:bars)
      should assign_to(:current_user)
      should respond_with(:success)
      should render_template(:index)
      should_not set_the_flash
    end

    context "while logged in as customer" do
      setup do
        sign_in :customer
        get :index
      end

      should_not assign_to(:bars)
      should assign_to(:current_user)
      should respond_with(:redirect)
      should redirect_to("the home page"){ root_url }
      should set_the_flash.to("You do not have the correct privileges to access this page")
    end
  end


  #show
  context "GET to show" do
    context "while logged in as admin" do
      setup do
        sign_in :admin
        get :show, :id => bars(:active_bar)
      end

      should assign_to(:bar)
      should assign_to(:vouchers)
      should assign_to(:current_user)
      should respond_with(:success)
      should render_template(:show)
      should_not set_the_flash
    end

    context "while logged in as customer" do
      setup do
        sign_in :customer
        get :show, :id => bars(:active_bar)
      end

      should_not assign_to(:bar)
      should assign_to(:current_user)
      should respond_with(:redirect)
      should redirect_to("the home page"){ root_url }
      should set_the_flash.to("You do not have the correct privileges to access this page")
    end
    
    context "and passing friendly id with the wrong locale" do
      setup { get :show, :id => bars(:active_bar).slug_en, :locale => :de }
      
      should respond_with(:redirect)
    end    
    
  end

  #new

  #create
  context "POST to CREATE" do
    setup do
      sign_in :admin
      city = Factory(:city)
      post :create, :bar => Factory.attributes_for(:bar, :country => city.country, :city => city)
    end
    
    should assign_to(:bar)
    should "save bar" do
      assert assigns(:bar).persisted?, "bar didn't save: #{assigns(:bar).errors.full_messages}"
    end
    should "not be pending" do
      assert !assigns(:bar).pending
    end
  end

  #edit
  context "GET to edit" do
    context "while logged in as admin" do
      setup do
        sign_in :admin
        get :edit, :id => bars(:active_bar).id
      end

      should assign_to(:bar)
      should assign_to(:current_user)
      should respond_with(:success)
      should render_template(:edit)
      should_not set_the_flash

      should "have a bar that's not a new record" do
        assert_equal assigns(:bar).new_record?, false
      end
    end

    context "while logged in as customer" do
      setup do
        sign_in :customer
        get :edit, :id => bars(:active_bar).id
      end

      should_not assign_to(:bar)
      should assign_to(:current_user)
      should respond_with(:redirect)
      should redirect_to("the home page"){ root_url }
      should set_the_flash.to("You do not have the correct privileges to access this page")
    end
  end
  
  # update
  context "PUT to update" do
    context "and logged in as affilaite" do
      setup { sign_in(:admin) }
      
      context "and updating the bar's information" do
        setup do
          put :update, :id => bars(:inactive_bar).id, :bar => {:url => "www.website.com"}
        end
    
        should assign_to(:bar)
        should assign_to(:current_user)
        should respond_with(:redirect)
        should redirect_to("the bar's page"){ admin_bar_url(assigns(:bar)) }
      
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
          should redirect_to("the bar's page"){ admin_bar_url(assigns(:bar)) }
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
          should redirect_to("the bar's page"){ admin_bar_url(assigns(:bar)) }
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
          should redirect_to("the bar's page"){ admin_bar_url(assigns(:bar)) }
          should set_the_flash.to("Vouchers Redeemed: 1")
          
          should "have a change in redeemable vouchers" do
            assert_equal 1, @voucher_count - bars(:active_bar).vouchers(true).redeemable.size
          end
        end
      end
    
    end
  end
  
  #vouchers
  
  context "GET to vouchers" do
    context "while logged in as admin" do
      setup do
        sign_in :admin
        get :vouchers, :id => bars(:active_bar).id
      end
    
      should assign_to(:bar)
      should assign_to(:voucher_lists)
      should assign_to(:current_user)
      should respond_with(:success)
      should render_template(:vouchers)
      should_not set_the_flash
      
      should "have the same amout of vouchers as the bar" do
        assert_equal assigns(:bar).voucher_lists.valid, assigns(:voucher_lists)
      end
    end
    
    context "while logged in as admin and posting a specific price" do
      setup do
        sign_in :admin
        get :vouchers, :id => bars(:active_bar).id, :price => 499
      end
    
      should assign_to(:bar)
      should assign_to(:voucher_lists)
      should assign_to(:current_user)
      should respond_with(:success)
      should render_template(:vouchers)
      should_not set_the_flash
      
      should "have the same amount of vouchers as the bar" do
        assert_equal assigns(:bar).voucher_lists.valid.find_all_by_cents(499), assigns(:voucher_lists)
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
  
  # destroy
  context "PUT to destroy" do
    context "while logged in as admin" do
      setup do
        sign_in :admin
        put :destroy, :id => bars(:active_bar).id
      end

      should assign_to(:bar)
      should assign_to(:current_user)
      should respond_with(:redirect)
      should redirect_to("the bar index page"){ admin_bars_url }
      should set_the_flash.to("Bar removed!")

      should "delete the bar's associated prices" do
        assert Price.find_all_by_bar_id(bars(:active_bar).id).empty?
      end
    end

    context "while logged in as customer" do
      setup do
        sign_in :customer
        put :destroy, :id => bars(:active_bar).id
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
    
    context "while logged in as admin" do
      setup do
        sign_in :admin
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