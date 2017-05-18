require 'test_helper'

class SiteAdminTest < ActiveSupport::TestCase
  setup { @site_admin = Factory.build(:site_admin) }

  should have_many(:sites).through(:site_admin_sites)
end
