require 'test_helper'

class BroTest < ActiveSupport::TestCase
  should have_many(:bars)
end
