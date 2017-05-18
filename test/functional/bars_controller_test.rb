require 'test_helper'

class BarsControllerTest < ActionController::TestCase

  # Bars/New
  context "GET to :new" do
    setup { get :new }

    should assign_to(:bar)
    should respond_with(:success)
    should render_template(:new)
    should_not set_the_flash

    should "have a new bar record" do
      assert assigns(:bar).new_record?
    end

    should "have prices" do
      assert_not_nil assigns(:bar).prices
    end
  end

  # Bars/Create
  context "POST to :create" do
    context "and posting all correct attributes" do
      setup do
        country = Factory(:country)
        post :create, :bar => Factory.attributes_for(:bar, :country_id => country.id, :city_id => Factory(:city, :country => country).id)
      end

      should assign_to(:bar)
      should respond_with(:redirect)
      should redirect_to("the confirm bar page"){ confirm_bar_path(assigns(:bar)) }

      should "not be a new record" do
        assert_false assigns(:bar).new_record?
      end

      should "not be active" do
        assert_false assigns(:bar).active?
      end

      should "be pending" do
        assert assigns(:bar).pending
      end

      should "be geocoded" do
        coords = Geokit::Geocoders::MultiGeocoder.geocode(assigns(:bar).full_address)
        assert assigns(:bar).geocoded?, "coords.all.size: #{coords.all.size} address: #{assigns(:bar).full_address}"
      end

      should "not create a new Delayed Job" do
        assert_equal 0, Delayed::Job.count
      end

      should "have no prices" do
        assert assigns(:bar).prices.blank?
      end

      should "have be associated with the current site" do
        assert @controller.current_site.bars.include?(assigns(:bar))
      end
    end

    context "and posting a new city" do
      setup do
        assert_difference "Bar.count" do
          post :create, {:bar => Factory.attributes_for(:bar, :country_id => Factory(:country).id, :city_id => nil)}.merge(:new_city_name => "Hamburg")
        end
      end

      should assign_to(:bar)
      should respond_with(:redirect)
      should redirect_to("the confirm bar page"){ confirm_bar_path(assigns(:bar)) }
    end

    context "and posting a no city" do
      setup do
        assert_no_difference "Bar.count" do
          post :create, {:bar => Factory.attributes_for(:bar, :country_id => Factory(:country).id, :city_id => nil)}.merge(:new_city_name => "")
        end
      end

      should assign_to(:bar)
      should respond_with(:success)
      should render_template(:new)
      should set_the_flash.to("Oh noes! Something went wrong.")

      should "have errors on bar instance" do
        assert_not_nil assigns(:bar).errors
      end
    end

    context "and posting incorrect attributes" do
      setup do
        assert_no_difference "Bar.count" do
          post :create, :bar => {:city_id => nil, :country_id => nil, :name => nil, :contact_email => nil, :contact_name => nil, :phone_number => nil}
        end
      end

      should assign_to(:bar)
      should respond_with(:success)
      should render_template(:new)
      should set_the_flash.to("Oh noes! Something went wrong.")

      should "have errors on bar instance" do
        assert_not_nil assigns(:bar).errors[:city_id]
        assert_not_nil assigns(:bar).errors[:country_id]
        assert_not_nil assigns(:bar).errors[:name]
        assert_not_nil assigns(:bar).errors[:contact_email]
        assert_not_nil assigns(:bar).errors[:contact_name]
        assert_not_nil assigns(:bar).errors[:phone_number]
      end
      
      should "have prices" do
        assert_not_nil assigns(:bar).prices
      end
    end
  end

  # bars / index
  context "GET to :index" do
    setup { @bar = Factory(:bar, :active => true) }

    context "without params" do
      setup { get :index }
      should assign_to(:bars)
      should respond_with(:success)
      should render_template(:index)
      should_not set_the_flash
    end

    context "with params" do
      setup { get :index, :origin => {:location => "Stargarder str. 80, 10437 Berlin", :distance => 5} }
      should assign_to(:bars)
      should respond_with(:success)
      should render_template(:index)
      should_not set_the_flash
    end

    should "scope bars by current site" do
      get :index
      assert assigns(:bars).include?(@bar)
    end

    should "not find bar when on different site" do
      #pend("This test requires default views, which are removed for now.")
      site = Factory(:site)
      @request.stubs(:subdomains).returns([site.subdomain])
      get :index
      assert_false assigns(:bars).include?(@bar)
    end
  end

  # bars / show
  context "GET to :show" do
    setup { @bar = Factory(:bar, :active => true) }

    context "and passing id" do
      setup { get :show, :id => @bar.id }
      should respond_with(:success)
    end

    context "and passing friendly id" do
      setup { get :show, :id => @bar.friendly_id }
      should assign_to(:bar)
      should assign_to(:feed)
      should assign_to(:noindex) # because there is no description
      
      should respond_with(:success)
      should render_template(:show)
    end
    
    context "and passing friendly id with the wrong locale" do
      setup { get :show, :id => @bar.slug_en, :locale => :de }
      
      should respond_with(:redirect)
    end
    
    context "with an empty description" do
      setup do
        @bar.description = ""
        @bar.save!
        get :show, :id => @bar.friendly_id
      end
      
      should_not assign_to(:noindex)
    end
  end

  # bars / edit
  context "GET to edit" do
    context "when bar is active" do
      setup do
        @bar = Factory(:bar, :active => true)
        get :edit, :id => @bar.id
      end

      should assign_to(:bar)
      should respond_with(:redirect)
      should redirect_to("the root url") { root_url }
      should set_the_flash.to("You do not have the correct privileges to access this page")
    end

    context "when the bar is inactive but not pending" do
      setup do
        @bar = Factory(:bar, :active => false, :pending => false)
        get :edit, :id => @bar.id
      end

      should assign_to(:bar)
      should respond_with(:redirect)
      should redirect_to("the root url") { root_url }
      should set_the_flash.to("You do not have the correct privileges to access this page")
    end

    context "when the bar is pending" do
      setup do
        @bar = Factory(:bar, :active => false, :pending => true)
        get :edit, :id => @bar.id
      end

      should assign_to(:bar)
      should respond_with(:success)
      should render_template(:edit)
      should_not set_the_flash
    end
  end

  # bars / update
  context "POST to update" do
    context "when bar is active" do
      setup do
        @bar = Factory(:bar, :active => true, :pending => false)
        post :update, :id => @bar.id, :bar => {:name => "changed"}
      end

      should assign_to(:bar)
      should respond_with(:redirect)
      should redirect_to("the root url") { root_url }
      should set_the_flash.to("You do not have the correct privileges to access this page")
    end

    context "when the bar is inactive but not pending" do
      setup do
        @bar = Factory(:bar, :active => false, :pending => false)
        post :update, :id => @bar.id, :bar => {:name => "changed"}
      end

      should assign_to(:bar)
      should respond_with(:redirect)
      should redirect_to("the root url") { root_url }
      should set_the_flash.to("You do not have the correct privileges to access this page")
    end

    context "when the bar is pending" do
      setup do
        @bar = Factory(:bar, :active => false, :pending => true)
        post :update, :id => @bar.id, :bar => {:name => "changed"}
      end

      should assign_to(:bar)
      should respond_with(:redirect)
      should redirect_to("the confirmation page") { confirm_bar_url(assigns(:bar)) }
    end
  end

  # bars / confirm
  context "GET to confirm" do
    context "when bar is active" do
      setup do
        @bar = Factory(:bar, :active => true, :pending => false)
        get :confirm, :id => @bar.id
      end

      should assign_to(:bar)
      should respond_with(:redirect)
      should redirect_to("the root url") { root_url }
      should set_the_flash.to("You do not have the correct privileges to access this page")
    end

    context "when the bar is inactive but not pending" do
      setup do
        @bar = Factory(:bar, :active => false, :pending => false)
        get :confirm, :id => @bar.id
      end

      should assign_to(:bar)
      should assign_to(:menu)
      should respond_with(:success)
      should render_template(:confirm)
    end

    context "when the bar is pending" do
      setup do
        @bar = Factory(:bar, :active => false, :pending => true)
        get :confirm, :id => @bar.id
      end

      should assign_to(:bar)
      should assign_to(:menu)
      should respond_with(:success)
      should render_template(:confirm)
    end
  end

  # bars / submit
  context "POST to submit" do
    context "when bar is active" do
      setup do
        @bar = Factory(:bar, :active => true, :pending => false)
        post :submit, :id => @bar.id
      end

      should assign_to(:bar)
      should respond_with(:redirect)
      should redirect_to("the root url") { root_url }
      should set_the_flash.to("You do not have the correct privileges to access this page")
    end

    context "when the bar is inactive but not pending" do
      setup do
        @bar = Factory(:bar, :active => false, :pending => false)
        post :submit, :id => @bar.id
      end

      should assign_to(:bar)
      should respond_with(:redirect)
      should redirect_to("the root url") { root_url }
      should set_the_flash.to("You do not have the correct privileges to access this page")
    end

    context "when the bar is pending" do
      setup do
        @bar = Factory(:bar, :active => false, :pending => true)
        @email_length = ActionMailer::Base.deliveries.length
        post :submit, :id => @bar.id
      end

      should assign_to(:bar)
      should respond_with(:redirect)
      should set_the_flash.to("We've successfully received all your information and will get back to you as soon as possible about your Buddy bar membership. Thanks again!")
      should redirect_to("the bar confirm page") { confirm_bar_url(assigns(:bar)) }

      should "no longer be pending" do
        assert_false assigns(:bar).pending?
      end

      should "still not be active" do
        assert_false assigns(:bar).active?
      end

      should "send an email" do
        assert_equal 1, ActionMailer::Base.deliveries.length - @email_length
      end
    end
  end
end
