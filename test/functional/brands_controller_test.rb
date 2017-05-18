require 'test_helper'

class BrandsControllerTest < ActionController::TestCase
  
  #index
  context "GET to :index" do
    setup { get :index }
    
    should assign_to(:brands)
  end
  
  context "POST to add_brand" do
    setup do
      @brand_count = Brand.all.size
      post :add_brand, :brand => {:name => "Skullfuck", :beverage_id => Factory(:beverage).id}
    end
    
    should assign_to(:brand)
    
    should respond_with_content_type('text/html')
    should_not render_with_layout
    
    should "render the correct text" do
      assert_response_equals("Skullfuck")
    end
    
    should "not be a new record" do
      assert !assigns(:brand).new_record?
    end
    
    should "have a one more brand" do
      assert_equal 1, Brand.all.size - @brand_count
    end
  end

end
