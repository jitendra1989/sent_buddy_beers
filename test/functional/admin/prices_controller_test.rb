require 'test_helper'

class Admin::PricesControllerTest < ActionController::TestCase
  fixtures :users, :bars, :beers, :prices, :countries, :cities, :brands

  context "GET to :index" do
    context "while logged in as admin" do
      setup do
        sign_in :admin
        get :index, :bar_id => bars(:active_bar).id
      end

      should assign_to(:menu)
      should assign_to(:price)
      should assign_to(:bar)
      should assign_to(:current_user)
      should respond_with(:success)
      should render_template(:index)
      should_not set_the_flash

      should "have a new record price" do
        assert assigns(:price).new_record?
      end

      should "have a price instance with a zero price" do
        assert_equal assigns(:price).cents, 0
      end

      should "have a menu containing the bars prices" do
        assert_equal assigns(:menu), assigns(:bar).prices
        assert_equal assigns(:menu).length, assigns(:bar).prices.length
      end
    end

    context "when logged in as customer" do
      setup do
        sign_in :customer
        get :index, :bar_id => bars(:active_bar).id
      end

      should_not assign_to(:price)
      should_not assign_to(:bar)
      should_not assign_to(:menu)
      should assign_to(:current_user)
      should respond_with(:redirect)
      should redirect_to("the home page"){ root_url }
      should set_the_flash.to("You do not have the correct privileges to access this page")
    end
  end

  context "POST to :create" do
    context "while logged in as admin" do
      setup { sign_in :admin }
      context "when posting a new price" do
        setup do
          post :create, :bar_id => bars(:active_bar).id, :price => {:beer_id => beers(:pilsner).id, :bar_id => bars(:active_bar).id, :amount => "2.00", :name => "New Beer"}
        end

        should assign_to(:price)
        should assign_to(:bar)
        should assign_to(:current_user)
        should redirect_to("the price list page"){ admin_bar_prices_url(assigns(:bar)) }
        should set_the_flash.to("New Beer Added")

        should "have accurate cents" do
          assert_equal assigns(:price).cents, 200
        end
      end
      
      context "when posting a price with a different currency" do
        setup do
          post :create, :bar_id => bars(:active_bar).id, :price => {:beer_id => beers(:pilsner).id, :bar_id => bars(:active_bar).id, :amount => "2.00", :currency => "USD", :name => "New Beer"}
        end
        should assign_to(:price)
        should assign_to(:bar)
        should assign_to(:current_user)
        should redirect_to("the price list page"){ admin_bar_prices_url(assigns(:bar)) }
        should set_the_flash.to("New Beer Added")

        should "have the correct currency" do
          assert_equal assigns(:price).currency, "USD"
        end
      end
      
    end
  end

  context "PUT to :update" do
    context "while logged in as admin" do
      setup { sign_in :admin }
      context "and posting the correct attributes" do
        setup do
          put :update, :id => prices(:one).id, :bar_id => bars(:active_bar).id, :price => { :beer_id => beers(:pilsner).id, :amount => "2.50", :name => "Old Beer"}
        end

        should assign_to(:price)
        should assign_to(:bar)
        should assign_to(:current_user)
        should redirect_to("the price list page"){ admin_bar_prices_url(assigns(:bar)) }
        should set_the_flash.to("Price updated")

        should "have accurate cents" do
          assert_equal assigns(:price).cents, 250
        end
      end
      context "and positing incorrect attributes" do
        setup do
          put :update, :id => prices(:one).id, :bar_id => bars(:active_bar).id, :price => {:beer_id => beers(:pilsner).id, :amount => "0.00"}
        end

        should assign_to(:price)
        should assign_to(:bar)
        should assign_to(:current_user)
        should render_template(:edit)
        should set_the_flash.to("Error Updating Price.")

        should "have errors on amount" do
          assert assigns(:price).errors[:cents]
        end
      end
    end
  end

end
