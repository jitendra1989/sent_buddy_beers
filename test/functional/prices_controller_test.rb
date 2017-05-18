require 'test_helper'

class PricesControllerTest < ActionController::TestCase

  fixtures :bars, :beers, :brands, :prices

  # prices / new
  context "GET to new" do
    context "when bar is active" do
      setup { get :new, :bar_id => bars(:active_bar) }

      should assign_to(:bar)
      should respond_with(:redirect)
      should redirect_to("the root url"){ root_url }
      should set_the_flash.to("You do not have the correct privileges to access this page")
    end

    context "when the bar is inactive but not pending" do
      setup { get :new, :bar_id => bars(:inactive_bar) }

      should assign_to(:bar)
      should respond_with(:redirect)
      should redirect_to("the root url"){ root_url }
      should set_the_flash.to("You do not have the correct privileges to access this page")
    end

    context "when the bar is pending" do
      setup { get :new, :bar_id => bars(:pending_bar) }

      should assign_to(:bar)
      should assign_to(:price)
      should assign_to(:menu)
      should respond_with(:success)
      should render_template(:new)
      should_not set_the_flash

      should "be a new record" do
        assert assigns(:price).new_record?
      end
    end
  end

  # prices / create
  context "POST to create" do
    context "when bar is active" do
      setup { post :create, :price => price_params, :bar_id => bars(:active_bar) }

      should assign_to(:bar)
      should respond_with(:redirect)
      should redirect_to("the root url"){ root_url }
      should set_the_flash.to("You do not have the correct privileges to access this page")
    end

    context "when the bar is inactive but not pending" do
      setup { post :create, :price => price_params, :bar_id => bars(:inactive_bar) }

      should assign_to(:bar)
      should respond_with(:redirect)
      should redirect_to("the root url"){ root_url }
      should set_the_flash.to("You do not have the correct privileges to access this page")
    end

    context "when the bar is pending" do
      setup do
        @beer_count = Beer.count
        @price_count = Price.count
      end

      context "and posting correct attributes" do
        setup { post :create, :price => price_params, :bar_id => bars(:pending_bar).id }

        should assign_to(:bar)
        should assign_to(:price)
        should respond_with(:redirect)
        should redirect_to("the new price page"){ new_bar_price_path(assigns(:bar)) }
        should set_the_flash.to("New Beer Added")

        should "not be a new record" do
          assert !assigns(:price).new_record?
        end

        should "have a new price" do
          assert_equal 1, Price.count - @price_count
        end

        should "not have a new beer" do
          assert_equal 0, Beer.count - @beer_count
        end
      end

      context "and posting correct attributes plus a new beer" do
        setup { post :create, :price => price_params, :beer => {:name => "Schlitz", :brand_id => brands(:berliner).id}, :bar_id => bars(:pending_bar).id }

        should assign_to(:bar)
        should assign_to(:price)
        should assign_to(:beer)
        should respond_with(:redirect)
        should redirect_to("the new price page"){ new_bar_price_path(assigns(:bar)) }
        should set_the_flash.to("New Beer Added")

        should "not be a new record" do
          assert !assigns(:price).new_record?
        end

        should "have a new price" do
          assert_equal 1, Price.count - @price_count
        end

        should "have a new beer" do
          assert_equal 1, Beer.count - @beer_count
        end

        should "be attached to the new beer" do
          assert assigns(:price).beer.name == "Schlitz", "!!!!!!!!!#{assigns(:beer).name}"
        end
      end
    end
  end

  # prices / destroy
  context "PUT to destroy" do
    context "when bar is active" do
      setup { put :destroy, :id => bars(:active_bar).prices.first.id, :bar_id => bars(:active_bar) }

      should assign_to(:bar)
      should_not assign_to(:price)
      should respond_with(:redirect)
      should redirect_to("the root url"){ root_url }
      should set_the_flash.to("You do not have the correct privileges to access this page")
    end

    context "when the bar is inactive but not pending" do
      setup { put :destroy, :id => bars(:inactive_bar).prices.first.id, :bar_id => bars(:inactive_bar) }

      should assign_to(:bar)
      should_not assign_to(:price)
      should respond_with(:redirect)
      should redirect_to("the root url"){ root_url }
      should set_the_flash.to("You do not have the correct privileges to access this page")
    end

    context "when the bar is pending" do
      setup do
        Price.create(:amount => "2.50", :name => "BrewDog", :beer_id => beers(:pilsner), :bar_id => bars(:pending_bar).id)
        @price_count = Price.count
        put :destroy, :id => bars(:pending_bar).prices(true).first.id, :bar_id => bars(:pending_bar)
      end
      should assign_to(:bar)
      should assign_to(:price)
      should respond_with(:redirect)
      should redirect_to("the new price page"){ new_bar_price_url(assigns(:bar)) }

      should "have one less price" do
        assert_equal -1, Price.count - @price_count
      end
    end
  end

  # prices /get_prices_for_select_from_bar AJAX
  context "POST to get_prices_for_select_from_bar" do
    setup do
      post :get_prices_for_select_from_bar, :id => bars(:active_bar)
    end

    should assign_to(:prices)
    should_not assign_to(:bar)

    should "not be blank" do
      assert assigns(:prices).present?
    end
  end

protected
  def price_params
    {:beer_id => beers(:pilsner).id, :amount => "2.50", :name => "Brewskie"}
  end

end
