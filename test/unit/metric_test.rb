require 'test_helper'

class MetricTest < ActiveSupport::TestCase

  should belong_to(:user)
  should validate_presence_of(:name)
  should validate_presence_of(:value)
  
end
