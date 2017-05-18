require 'test_helper'

class CountryTest < ActiveSupport::TestCase
  setup { @country = Factory(:country) }

  should have_many(:bars)
  should have_many(:cities)

  should validate_presence_of(:iso)
  should validate_presence_of(:name)
  should validate_presence_of(:printable_name)
  should validate_presence_of(:iso3)
  should validate_presence_of(:numcode)
  should validate_uniqueness_of(:iso)
  should validate_uniqueness_of(:name)
  should validate_uniqueness_of(:iso3)
  should validate_uniqueness_of(:numcode)
  should validate_numericality_of(:numcode)

  should "return only records with active bars" do
    Factory(:bar, :country => @country, :active => true)
    Factory(:bar, :active => false)
    assert_equal [@country], Country.with_active_bars.all
  end

  should "return only records with bars associated with given site on #for_site" do
    site_1 = Factory(:site)
    site_2 = Factory(:site)
    bar_1 = Factory(:bar, :sites => [site_1], :country => @country)
    bar_2 = Factory(:bar, :sites => [site_2])

    assert Country.with_bars_for_site(site_1).include?(@country)
    assert !Country.with_bars_for_site(site_2).include?(@country)
  end
end
