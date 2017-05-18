require "integration_test_helper"

class Admin::SiteAdminsTest < ActionController::IntegrationTest
  setup { sign_in :admin }

  should "display list of site admins" do
    Factory(:site_admin, :name => "Pat Garret")

    visit admin_site_admins_path

    assert page.has_content?("Pat Garret")
  end

  should "create site admin" do
    site = Factory(:site, :name => "Pilsner")

    visit new_admin_site_admin_path

    check "Pilsner"
    fill_in "Name", :with => "Billy Kid"
    fill_in "Username", :with => "billy"
    fill_in "site_admin_emails_attributes_0_email", :with => "billy@kid.com"
    fill_in "Choose Password", :with => "secret"
    fill_in "Confirm Password", :with => "secret"
    click_button "Create Site admin"

    site_admin = SiteAdmin.find_by_name("Billy Kid")
    assert_not_nil site_admin
    assert_include site_admin.sites, site
  end

  should "update site admin" do
    site = Factory(:site, :name => "Pilsner")
    site_admin = Factory(:site_admin, :name => "Pat Garret", :sites => [site])

    visit edit_admin_site_admin_path(site_admin)

    uncheck "Pilsner"
    fill_in "Name", :with => "Patrick Floyd Garrett"
    click_button "Update Site admin"

    assert_equal "Patrick Floyd Garrett", site_admin.reload.name
    assert_not_include site_admin.sites, site
  end
end
