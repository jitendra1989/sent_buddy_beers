require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  should "return underscored class name of object on #namespace_for" do
    assert_equal "affiliate", namespace_for(Affiliate.new)
    assert_equal "site_admin", namespace_for(SiteAdmin.new)
  end
end
