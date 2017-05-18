require "integration_test_helper"

class Admin::SitesTest < ActionController::IntegrationTest
  setup do
    @site = Factory(:site, :name => "Tyskie")
    sign_in :admin
  end

  should "display list of sites" do
    visit admin_sites_path

    assert page.has_content?('BuddyBeers')
    assert page.has_content?('Tyskie')
  end

  should "display site details" do
    visit admin_site_path(@site)

    assert page.has_content?('Tyskie')
    assert page.has_content?('tyskie')
  end

  should "update site" do
    visit edit_admin_site_path(@site)

    fill_in "Name", :with => "Lech"
    fill_in "Facebook app id", :with => "123"
    fill_in "Facebook app secret", :with => "abc"
    click_button "Update"

    @site.reload

    assert_equal admin_site_path(@site), current_path
    assert_equal "Lech", @site.name
    assert_equal "123", @site.facebook_app_id
    assert_equal "abc", @site.facebook_app_secret
  end
end
