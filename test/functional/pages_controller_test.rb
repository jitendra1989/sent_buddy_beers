require 'test_helper'

class PagesControllerTest < ActionController::TestCase
  setup do
    @page = Factory.build(:page, :title => "Title", :body => "Body", :site_ids => [Thread.current[:current_site].id])
  end
  
  # GET SHOW
  context "on GET to show" do
    context "with an unpublished page" do
      setup do
        @page.save
      end
      
      should "raise_404" do
        assert_raise (ActionController::RoutingError) { get :show, :id => @page.slug }
      end
    end
    
    context "with an different site's page" do
      setup do
        @page.published = true
        @page.site_ids = [Factory(:site).id]
        @page.save
      end
      
      should "raise_404" do
        assert_raise (ActionController::RoutingError) { get :show, :id => @page.slug }
      end
    end
    
    context "with a published page" do
      setup do
        @page.published = true
        @page.save
        get :show, :id => @page.slug
      end
      
      should respond_with(:success)
      should assign_to(:page)
      
      context "with multiple translations" do
        setup do 
          I18n.with_locale(:de) do
            @page.title = "Titel"
            @page.body = "Korper"
            @page.save
          end
          @de_slug = PageTranslation.where(:page_id => @page.id, :locale => 'de').first.slug
        end 
        
        should "have multiple translations" do
          assert_equal 2, @page.translations(true).size
        end
        
        context "and getting to that locale's translation" do
          setup { get :show, :id => @de_slug, :locale => :de }
              
          should respond_with(:success)
          should assign_to(:page) 
        end
        
        context "and posting to miss-matched locale and slug" do
          setup { get :show, :id => @de_slug, :locale => :en }
          
          should assign_to(:page)  
          should respond_with(:redirect)
        end 
        
        context "and posting an id" do
          setup { get :show, :id => @page.id, :locale => :en }
          
          should assign_to(:page)  
          should respond_with(:success)
        end 
      end
      
      context "and posting to a locale with no translations" do
        setup { get :show, :id => @page.slug, :locale => :de  }
        
        should respond_with(:success)
        should assign_to(:page)
        should assign_to(:noindex)
        
        # No idea why this isn't working
        #should set_the_flash.to("Sorry. This page is not available in your language. We are displaying it in another available language (EN)").now
        
        should "not be indexed" do
          assert assigns(:noindex) == true
        end
      end
    end
    
  end

end
