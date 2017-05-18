require 'test_helper'

class SubdomainViewPathsController < ApplicationController
  def index
    head :ok
  end
end

class SubdomainViewPathsControllerTest < ActionController::TestCase
  should "prepend the default site subdomain and default paths to view paths if there's no subdomain" do
    with_test_route_set do
      site_view_paths = ["app/views/buddybeers", "app/views/default"]
      site_pathset = ActionView::Base.process_view_paths(site_view_paths)
      @request.stubs(:subdomains).returns([])

      get :index

      assert_equal site_pathset, @controller.view_paths.first(2)
      assert_equal site_pathset, ActionMailer::Base.view_paths.first(2)
    end
  end

  # Removed this test because we need www. subdomains \
  # should "redirect to the site without any subdomain if subdomain doesn't match any existing sites" do
  #     with_test_route_set do
  #       site_view_paths = ["app/views/buddybeers", "app/views/default"]
  #       site_pathset = ActionView::Base.process_view_paths(site_view_paths)
  #       @request.stubs(:subdomains).returns(["does-not-exist"])
  # 
  #       get :index
  # 
  #       assert_response :redirect
  #       assert_redirected_to root_path
  #     end
  #   end

  should "prepend site subdomain and default paths to view paths if subdomain matches one of the sites" do
    with_test_route_set do
      site = Factory(:site, :name => "Tyskie")
      site_view_paths = ["app/views/#{site.code_name}", "app/views/default"]
      site_pathset = ActionView::Base.process_view_paths(site_view_paths)
      @request.stubs(:subdomains).returns([site.subdomain])

      get :index

      assert_equal site_pathset, @controller.view_paths.first(2)
      assert_equal site_pathset, ActionMailer::Base.view_paths.first(2)
    end
  end

  should "prepend site subdomain and default paths to view paths if subdomain matches one of the sites and has 'www' prefix" do
    with_test_route_set do
      site = Factory(:site, :name => "Tyskie")
      site_view_paths = ["app/views/#{site.code_name}", "app/views/default"]
      site_pathset = ActionView::Base.process_view_paths(site_view_paths)
      @request.stubs(:subdomains).returns(["www", site.subdomain])

      get :index

      assert_equal site_pathset, @controller.view_paths.first(2)
      assert_equal site_pathset, ActionMailer::Base.view_paths.first(2)
    end
  end


  private

  def with_test_route_set
    with_routing do |set|
      set.draw do
        filter "locale"
        get "page", :to => "subdomain_view_paths#index"
        root :to => "home#index"
      end
      yield
    end
  end
end
