require 'test_helper'

class Affiliate::PricesControllerTest < ActionController::TestCase
  fixtures :users, :bars, :beers, :prices, :cities, :countries, :brands

  # INDEX

  context "GET to :index" do
    context "while logged in as affiliate" do
      setup do
        sign_in :affiliate
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

    context "while logged in as bro" do
      setup do
        sign_in :bro
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

  # CREATE

  context "POST to :create" do
    context "while logged in as affiliate" do
      setup do
        sign_in :affiliate
      end
      context "and posting all correct attributes" do
        setup do
          post :create, :bar_id => bars(:active_bar).id, :price => {:beer_id => beers(:pilsner).id, :bar_id => bars(:active_bar).id, :amount => "2.00", :name => "New Beer"}
        end

        should assign_to(:price)
        should assign_to(:bar)
        should assign_to(:current_user)
        should redirect_to("the price list page"){ affiliate_bar_prices_url(assigns(:bar)) }
        should set_the_flash.to("New Beer Added")

        should "have accurate cents" do
          assert_equal assigns(:price).cents, 200
        end
      end
      context "and posting a new beer" do
        setup do
          assert_difference "Beer.count" do
            post :create, :bar_id => bars(:active_bar).id, :price => {:beer_id => nil, :bar_id => bars(:active_bar).id, :amount => "2.00", :name => "New Beer"}, :beer => {:name => "New Beer", :brand_id => brands(:berliner).id}
          end
        end

        should assign_to(:price)
        should assign_to(:bar)
        should assign_to(:beer)
        should assign_to(:current_user)
        should redirect_to("the price list page"){ affiliate_bar_prices_url(assigns(:bar)) }
        should set_the_flash.to("New Beer Added")

        should "have accurate cents" do
          assert_equal assigns(:price).cents, 200
        end

        should "not return false for price being a new record" do
          assert_equal assigns(:price).new_record?, false
        end
      end
      context "and posting a drink with a different currency" do
        setup do
          post :create, :bar_id => bars(:active_bar).id, :price => {:beer_id => beers(:pilsner).id, :bar_id => bars(:active_bar).id, :amount => "2.00", :currency => "USD", :name => "New Beer"}
        end

        should assign_to(:price)
        should assign_to(:bar)
        should assign_to(:current_user)
        should redirect_to("the price list page"){ affiliate_bar_prices_url(assigns(:bar)) }
        should set_the_flash.to("New Beer Added")

        should "have the correct currency" do
          assert_equal assigns(:price).currency, "USD"
        end
      end
      context "and posting incorrect attributes" do
        setup do
          post :create, :bar_id => bars(:active_bar).id, :price => {:beer_id => "", :bar_id => "", :amount => "", :name => ""}
        end

        should assign_to(:price)
        should assign_to(:bar)
        should assign_to(:current_user)
        should respond_with(:success)
        should render_template(:index)
        should set_the_flash.to("Error Adding Beer. Did you enter an amount <em>and</em> a name?")

        should "return true for price being a new record" do
          assert assigns(:price).new_record?
        end
      end
    end

    context "while logged in as bro" do
      setup do
        sign_in :bro
      end
      context "and posting all correct attributes" do
        setup do
          post :create, :bar_id => bars(:active_bar).id, :price => {:beer_id => beers(:pilsner).id, :bar_id => bars(:active_bar).id, :amount => "2.00", :name => "New Beer"}
        end

        should assign_to(:price)
        should assign_to(:bar)
        should assign_to(:current_user)
        should redirect_to("the price list page"){ affiliate_bar_prices_url(assigns(:bar)) }
        should set_the_flash.to("New Beer Added")

        should "have accurate cents" do
          assert_equal assigns(:price).cents, 200
        end
      end
      context "and posting a new beer" do
        setup do
          assert_difference "Beer.count" do
            post :create, :bar_id => bars(:active_bar).id, :price => {:beer_id => nil, :bar_id => bars(:active_bar).id, :amount => "2.00", :name => "New Beer"}, :beer => {:name => "New Beer", :brand_id => brands(:berliner).id}
          end
        end

        should assign_to(:price)
        should assign_to(:bar)
        should assign_to(:beer)
        should assign_to(:current_user)
        should redirect_to("the price list page"){ affiliate_bar_prices_url(assigns(:bar)) }
        should set_the_flash.to("New Beer Added")

        should "have accurate cents" do
          assert_equal assigns(:price).cents, 200
        end

        should "not return false for price being a new record" do
          assert_equal assigns(:price).new_record?, false
        end
      end
      context "and posting incorrect attributes" do
        setup do
          post :create, :bar_id => bars(:active_bar).id, :price => {:beer_id => "", :bar_id => "", :amount => "", :name => ""}
        end

        should assign_to(:price)
        should assign_to(:bar)
        should assign_to(:current_user)
        should respond_with(:success)
        should render_template(:index)
        should set_the_flash.to("Error Adding Beer. Did you enter an amount <em>and</em> a name?")

        should "not return true for price being a new record" do
          assert assigns(:price).new_record?
        end
      end
    end
  end

  # UPDATE

  context "PUT to :update" do
    context "while logged in as affiliate" do
      setup do
        sign_in :affiliate
      end
      context "and posting all correct attributes" do
        setup do
          put :update, :id => prices(:one).id, :bar_id => bars(:active_bar).id, :price => {:amount => "2.50", :name => "New Beer"}
        end

        should assign_to(:price)
        should assign_to(:bar)
        should assign_to(:current_user)
        should redirect_to("the price list page"){ affiliate_bar_prices_url(assigns(:bar)) }
        should set_the_flash.to("Price updated")

        should "have accurate cents" do
          assert_equal assigns(:price).cents, 250
        end
      end

      context "and posting incorrect attributes" do
        setup do
          put :update, :id => prices(:one).id, :bar_id => bars(:active_bar).id, :price => {:amount => "", :name => ""}
        end

        should assign_to(:price)
        should assign_to(:bar)
        should assign_to(:current_user)
        should render_template(:edit)
        should set_the_flash.to("Error Updating Price.")
      end
    end

    context "while logged in as bro" do
      setup do
        sign_in :bro
      end
      context "and posting all correct attributes" do
        setup do
          put :update, :id => prices(:one).id, :bar_id => bars(:active_bar).id, :price => {:amount => "2.50", :name => "New Beer"}
        end

        should assign_to(:price)
        should assign_to(:bar)
        should assign_to(:current_user)
        should redirect_to("the price list page"){ affiliate_bar_prices_url(assigns(:bar)) }
        should set_the_flash.to("Price updated")

        should "have accurate cents" do
          assert_equal assigns(:price).cents, 250
        end
      end
      context "and posting incorrect attributes" do
        setup do
          put :update, :id => prices(:one).id, :bar_id => bars(:active_bar).id, :price => {:amount => "", :name => ""}
        end

        should assign_to(:price)
        should assign_to(:bar)
        should assign_to(:current_user)
        should render_template(:edit)
        should set_the_flash.to("Error Updating Price.")
      end
    end
  end

end
