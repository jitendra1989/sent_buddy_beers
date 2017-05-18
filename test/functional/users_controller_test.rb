require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  fixtures :users

  # users/index
  context "on GET to :index" do
    context "while logged in as a customer" do
      setup do
        sign_in(Factory(:customer))
        get :index, :q => "example"
      end
      
      should respond_with(:success)
      should assign_to(:current_user)
      should_not assign_to(:user)
      should_not render_with_layout
      should respond_with_content_type(:json)
      
      should "render nothing" do
        assert_response_contains("id")
        assert_response_contains("name")
        assert_response_contains("login")
        assert_response_contains("foobar")
        assert_response_contains("img_url")
        assert_response_contains("email")
        assert_response_contains("example.com")
      end
    end
  end
  
  # users/button
  context "on GET to :button" do
    
    setup do
      get :button, :id => users(:customer).id
    end
    
    should assign_to(:user)
    should assign_to(:name)
    
    should "be me" do
      assert assigns(:name) == "me"
    end
    
    should_not assign_to(:price)
    
    should "have a nil price" do
      assert assigns(:price).nil?
    end
    
    should assign_to(:drink)
    
    should "be beer" do
      assert assigns(:drink) == "beer"
    end
    
    should assign_to(:url_options)
    
    should "be just user id" do
      assert assigns(:url_options).has_key?(:user_id)
      assert !assigns(:url_options).has_key?(:price_id)
      assert !assigns(:url_options).has_key?(:bar_id)
    end
    
    context "and passing true as user name" do
      setup do
        get :button, :id => users(:customer).id, :name => true
      end
        
      should "assign users name to name" do
        assert_equal assigns(:name), users(:customer).to_s
      end
    end
    
    context "and passing alternate name as user name" do
      setup do
        get :button, :id => users(:customer).id, :name => "Ronald"
      end
        
      should "assign users name to name" do
        assert_equal assigns(:name), "Ronald"
      end
    end
    
    context "and passing alternate drink" do
      setup do
        get :button, :id => users(:customer).id, :drink => "Ronald Soda" 
      end
        
      should "assign drink name to drink" do
        assert_equal assigns(:drink), "Ronald Soda"
      end
    end
    
    context "and passing price" do
      setup do
        @price = Factory(:price)
        get :button, :id => users(:customer).id, :price_id => @price.id
      end
        
      should "assign price to price" do
        assert_equal assigns(:price), @price
      end
      
      should "have all url options" do
        assert assigns(:url_options).has_key?(:user_id)
        assert assigns(:url_options).has_key?(:price_id)
        assert assigns(:url_options).has_key?(:bar_id)
      end
      
      should "have drink be drink name" do
        assert_equal assigns(:drink), @price.name
      end
    end
    
    context "and passing location" do
      setup do
        @bar = Factory(:bar)
        get :button, :id => users(:customer).id, :location_id => @bar.id
      end
      
      should assign_to(:bar)
        
      should "assign bar to bar" do
        assert_equal assigns(:bar), @bar
      end
      
      should "have url options" do
        assert assigns(:url_options).has_key?(:user_id)
        assert !assigns(:url_options).has_key?(:price_id)
        assert assigns(:url_options).has_key?(:location_id)
      end
    end
  end

  # users/show

  # context "on GET to :show" do
  #   context "while not logged in" do
  #     setup { get :show, :id => users(:customer).id }
  # 
  #     should_not assign_to(:current_user)
  #     should_not assign_to(:user)
  #     should respond_with(:redirect)
  #     should set_the_flash.to("You must be logged in to access this page. <a href=\"/users/sign_up\">Click here to create your Buddy Account for free.</a>")
  #     should redirect_to("the user login page") { new_user_session_url }
  #   end
  # 
  #   context "while logged in" do
  #     context "and using an existing user's id" do
  #       setup do
  #         sign_in(:customer)
  #         get :show, :id => users(:customer).id
  #       end
  # 
  #       should assign_to(:current_user)
  #       should assign_to(:user)
  #       should respond_with(:success)
  #       should render_template(:show)
  #       should_not set_the_flash
  # 
  #       should "assign the same user as the id" do
  #         assert_equal assigns(:user), users(:customer)
  #       end
  #     end
  # 
  #     context "and using a bad user id" do
  #       setup do
  #         sign_in(:customer)
  #         get :show, :id => 100050
  #       end
  # 
  #       should assign_to(:current_user)
  #       should_not assign_to(:user)
  #       should respond_with(:redirect)
  #       should set_the_flash.to("Seems like this person doesn't exist. Sure you haven't had one too many?")
  #       should redirect_to("the home page"){ root_url }
  # 
  #       should "assign a nil user" do
  #         assert_nil assigns(:user)
  #       end
  #     end
  #   end
  # end
end
