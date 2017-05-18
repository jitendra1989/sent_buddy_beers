require 'test_helper'

class BeverageTest < ActiveSupport::TestCase
  setup { @beverage = Factory(:beverage) }

  should have_many(:brands)
  should have_many(:ious)
  should have_many(:beers).through(:brands)
  should have_many(:drink_types)
  should have_many(:prices)

  should validate_presence_of(:name)
  should validate_uniqueness_of(:name)

  should "render it's name when given #to_s" do
    assert_equal @beverage.to_s, @beverage.name
  end
  
  should "find a record related to beer for it's default" do
    assert_not_nil Beverage.default
  end
end
