require 'test_helper'

class HomeControllerTest < ActionController::TestCase

  setup do
    @terms = Factory(:page, :title => 'terms', :body => "terms and conditions", :published => true)
    @about = Factory(:page, :title => 'about', :body => "about buddy beers", :published => true)
    @impressum = Factory(:page, :title => 'impressum', :body => "impressum", :published => true)
    @privacy = Factory(:page, :title => 'privacy', :body => "our privates", :published => true)
    @terms.sites << Thread.current[:current_site]
    @about.sites << Thread.current[:current_site]
    @impressum.sites << Thread.current[:current_site]
    @privacy.sites << Thread.current[:current_site]
  end

  context "on GET to index" do
    setup { get :index }
    should respond_with(:success)
    should assign_to(:email_invitation)
    should assign_to(:activity)
    should render_template(:index)
  end
  
  context "on GET to privacy" do
    setup { get :privacy }
    should respond_with(:redirect)
    should redirect_to('privacy page'){ page_url(@privacy.slug) }
  end
  
  context "on GET to impressum" do
    setup { get :impressum }
    should respond_with(:redirect)
    should redirect_to('impressum page'){ page_url(@impressum.slug) }
  end
  
  context "on GET to about" do
    setup { get :about }
    should respond_with(:redirect)
    should redirect_to('about page'){ page_url(@about.slug) }
  end
  
  context "on GET to press" do
    setup { get :press }
    should respond_with(:success)
    should render_template(:press)
  end
  
  context "on GET to terms" do
    setup { get :terms }
    should respond_with(:redirect)
    should redirect_to('terms page'){ page_url(@terms.slug) }
  end
  
  context "on GET to iphone" do
    setup { get :iphone }
    should respond_with(:success)
    should render_template(:iphone)
  end
  
  context "on GET to apps" do
    setup { get :apps }
    should respond_with(:success)
    should assign_to(:email_invitation)
    should assign_to(:activity)
    should render_template(:apps)
  end
  

end
