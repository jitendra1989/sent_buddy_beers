require 'test_helper'

class SiteAdminSiteTest < ActiveSupport::TestCase
  setup { @site_admin_site = Factory(:site_admin_site) }

  should validate_presence_of(:site)
  should validate_presence_of(:site_admin)
  should validate_uniqueness_of(:site_id).scoped_to(:site_admin_id)
  should belong_to(:site)
  should belong_to(:site_admin)
end
