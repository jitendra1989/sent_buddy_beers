require 'test_helper'

class CityTest < ActiveSupport::TestCase
  setup { @city = Factory(:city) }

  should have_many(:bars)
  should belong_to(:country)
  should validate_presence_of(:name)
  should validate_presence_of(:country_id)

  should "return only records with active bars" do
    Factory(:bar, :city => @city, :active => true)
    Factory(:bar, :active => false)
    assert_equal [@city], City.with_active_bars.all
  end

  should "return only records with bars associated with given site on #for_site" do
    site_1 = Factory(:site)
    site_2 = Factory(:site)
    bar_1 = Factory(:bar, :sites => [site_1], :city => @city)
    bar_2 = Factory(:bar, :sites => [site_2])

    assert City.with_bars_for_site(site_1).include?(@city)
    assert !City.with_bars_for_site(site_2).include?(@city)
  end
end
