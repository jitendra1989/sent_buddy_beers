require 'test_helper'

class DrinkTypeTest < ActiveSupport::TestCase
  setup { @drink_type = Factory.build(:bottle) }

  should validate_presence_of(:beverage_id)
  should have_many(:prices)
  should belong_to(:beverage)

  should "render it's type when to_s is called" do
    assert_equal @drink_type.to_s, @drink_type.class.to_s
  end
end
