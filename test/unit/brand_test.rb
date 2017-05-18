require 'test_helper'

class BrandTest < ActiveSupport::TestCase
  setup { @brand = Factory(:brand) }

  should belong_to(:beverage)
  should have_many(:beers)
  should have_many(:ious)

  should validate_presence_of(:name)
  should validate_uniqueness_of(:name)

  should "render it's name when given #to_s" do
    assert_equal @brand.to_s, @brand.name
  end

  should "create an brand and a beer" do
    assert_difference 'Brand.count' do
      assert_difference 'Beer.count' do
        brand_attributes = Factory.attributes_for(:brand).merge(:beers_attributes => [{:name => "Skunk Beer"}])
        Brand.create!(brand_attributes)
      end
    end
  end
end
