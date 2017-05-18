require 'test_helper'

class BeerTest < ActiveSupport::TestCase
  setup { @beer = Factory(:beer) }

  should belong_to(:brand)
  should have_many(:ious)
  should have_many(:prices)
  should validate_presence_of(:name)

  should "render its name when sent #to_s" do
    assert_equal @beer.to_s, @beer.name
  end

  context "A beer instance without a brand" do
    setup do
      @beer = Factory(:beer, :brand => nil)
    end

    should "be able to be linked to a brand by calling link_to_brand(Brand)" do
      brand = Factory(:brand)
      assert_nil @beer.brand
      @beer.link_to_brand(brand)
      assert_not_nil @beer.brand
      assert_equal brand, @beer.brand
    end
  end
end
