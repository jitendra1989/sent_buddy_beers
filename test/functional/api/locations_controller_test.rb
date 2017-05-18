require 'test_helper'

class Api::LocationsControllerTest < ActionController::TestCase

  context "on GET to locations" do
    setup do 
      11.times { Factory(:bar) }
    end
    
    context "with no params" do
      setup { get :index }
    
      should assign_to(:locations)
      should respond_with(:success)
      should respond_with_content_type('application/json')
      should_not render_with_layout
      
      should "paginate locations" do
        assert_equal 10, assigns(:locations).length
      end
      
      # should "have the current site's active bars" do
      #   assert Bar.active.include?(assigns(:locations))
      # end
      
      should "render the correct json" do
        assert_response_contains("true")
        assert_response_contains("locations")
        assert_response_contains("total_pages")
        assert_response_contains("current_page")
      end
    end
    
    context "with page params" do
      setup { get :index, :page => 2 }
    
      should assign_to(:locations)
      should respond_with(:success)
      should respond_with_content_type('application/json')
      should_not render_with_layout
      
      should "paginate locations" do
        assert_equal 1, assigns(:locations).length
      end
      
      should "have the current site's active bars" do
        assert_equal assigns(:locations), [Bar.active.last]
      end
      
      should "render the correct json" do
        assert_response_contains("true")
        assert_response_contains("locations")
        assert_response_contains("total_pages")
        assert_response_contains("current_page")
      end
    end

    context "with query params" do
      setup do 
        Bar.last(6).each{ |b| b.update_attribute(:name, "Something Else") }
        get :index, :q => "Foo"
      end
    
      should assign_to(:locations)
      should respond_with(:success)
      should respond_with_content_type('application/json')
      should_not render_with_layout
      
      should "paginate locations" do
        assert_equal 5, assigns(:locations).length
      end
      # 
      # should "have the current site's active bars" do
      #   assert Bar.active.include?(assigns(:locations))
      # end
      
      should "should have 'Foo Bar' as the bar title" do
        assert_equal "Foo Bar", assigns(:locations).first.name
      end
      
      should "render the correct json" do
        assert_response_contains("true")
        assert_response_contains("locations")
        assert_response_contains("total_pages")
        assert_response_contains("current_page")
      end
    end

    context "with distance params" do
      setup do 
        country = Factory(:country, :printable_name => "Germany")
        city = Factory(:city, :name => "Berlin")
        Bar.last(6).each_with_index do |b, i| 
          b.city = city
          b.country = country
          b.address = "Stargarderstr. #{i}"
          b.save
        end
        get :index, :orgin => "Stargarderstr. 80, 10437 Berlin, Germany"
      end
    
      should assign_to(:locations)
      should respond_with(:success)
      should respond_with_content_type('application/json')
      should_not render_with_layout
      
      should "paginate locations" do
        assert_equal 10, assigns(:locations).length
      end
      
      # should "have the current site's active bars" do
      #   assert Bar.active.include?(assigns(:locations))
      # end
      
      should "should be geocoded" do
        assert assigns(:locations).first.geocoded?
      end
      
      should "render the correct json" do
        assert_response_contains("true")
        assert_response_contains("locations")
        assert_response_contains("total_pages")
        assert_response_contains("current_page")
      end
    end

    context "with blank params" do
      setup do 
        get :index, :q => "Something Else"
      end
    
      should assign_to(:locations)
      should respond_with(:success)
      should respond_with_content_type('application/json')
      should_not render_with_layout
      
      should "paginate locations" do
        assert_equal 10, assigns(:locations).length
      end
      
      # should "have the current site's active bars" do
      #        assert Bar.active.include?(assigns(:locations))
      #      end
      
      should "render the correct json" do
        assert_response_contains("false")
        assert_response_contains("errors")
        assert_response_contains("locations")
        assert_response_contains("total_pages")
        assert_response_contains("current_page")
      end
    end
  
  end

end
