require 'test_helper'

class FakeController < ApplicationController
  def index
    head :ok
  end
end

class FakeControllerTest < ActionController::TestCase
  should "render 404 if current site is not found" do
    with_test_route_set do
      Site.stubs(:find_for_domains).returns(nil)

      get :index

      assert_response :not_found
      assert_template :file => Rails.root.join("public/404.html")
    end
  end


  private

  def with_test_route_set
    with_routing do |set|
      set.draw do
        get "fake", :to => "fake#index"
      end
      yield
    end
  end
end
