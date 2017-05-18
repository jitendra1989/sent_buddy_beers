require 'test_helper'

class BarSiteTest < ActiveSupport::TestCase
  setup { @bar_site = Factory(:bar_site) }

  should validate_presence_of(:site)
  should validate_presence_of(:bar)
  should validate_uniqueness_of(:site_id).scoped_to(:bar_id)
  should belong_to(:site)
  should belong_to(:bar)
end
