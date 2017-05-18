require 'test_helper'

class BeersControllerTest < ActionController::TestCase

  fixtures :beers, :brands

  context "POST to get_beers_for_brand" do
    setup { post :get_beers_for_brand, :brand_id => brands(:berliner) }

    should assign_to(:beers)

    should "contain all the beers in a brand" do
      assert_equal assigns(:beers), brands(:berliner).beers
    end
  end

  context "POST to add_beer" do
    setup do
      @beer_count = Beer.all.length
      post :add_beer, :beer => {:brand_id => brands(:berliner).id, :name => "Buttfuck"}
    end

    should assign_to(:beer)
    should assign_to(:beers)

    should "not be a new record" do
      assert !assigns(:beer).new_record?
    end

    should "have created a new beer" do
      assert_equal 1, Beer.all.length - @beer_count
    end
  end
end
