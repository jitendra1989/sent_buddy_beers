require "integration_test_helper"

class SiteAdmin::AffiliatesTest < ActionController::IntegrationTest
  setup do
    @site = Factory(:site)
    @affiliate = Factory(:affiliate, :name => "Pat Garrett")
    @site_admin = Factory(:site_admin)
    sign_in @site_admin
  end

  should "display list of affiliates associated with site bar" do
    @site_admin.sites << @site
    @bar = Factory(:bar, :affiliate => @affiliate)
    @bar.sites << @site
    Factory(:affiliate, :name => "Billy Kid")

    visit site_admin_affiliates_path

    assert page.has_content?("Pat Garrett")
    #assert_false page.has_content?("Billy Kid") #for now we're showing all affiliates
  end

  should "create confirmed affiliate" do
    visit new_site_admin_affiliate_path

    fill_in "Username", :with => "billy"
    fill_in "affiliate_emails_attributes_0_email", :with => "billy@kid.com"
    fill_in "Choose Password", :with => "secret"
    fill_in "Confirm Password", :with => "secret"
    click_button "Create Affiliate"

    affiliate = Affiliate.where(:login => "billy").first
    assert affiliate
    assert affiliate.confirmed?
  end

  should "update existing affiliate" do
    @site_admin.sites << @site
    @bar = Factory(:bar, :affiliate => @affiliate)
    @bar.sites << @site

    visit edit_site_admin_affiliate_path(@affiliate)

    fill_in "Name", :with => "Patrick Floyd Garrett"
    click_button "Update Affiliate"
    assert_equal "Patrick Floyd Garrett", @affiliate.reload.name
  end
end
