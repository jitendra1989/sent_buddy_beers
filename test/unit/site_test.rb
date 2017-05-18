require 'test_helper'

class SiteTest < ActiveSupport::TestCase
  setup { @site = Factory.build(:site) }

  should have_many(:bars).through(:bar_sites)
  should have_many(:ious)
  should have_many(:credit_events)
  should have_and_belong_to_many(:pages)

  should validate_presence_of(:name)
  should validate_presence_of(:code_name)
  should_not allow_value("multiple.domain").for(:subdomain)
  should_not allow_value("*").for(:subdomain)
  should_not allow_value("www").for(:subdomain)

  should "not allow to change code_name on update" do
    @site.save!
    @site.update_attributes(:code_name => "changed")
    assert_not_equal "changed", @site.reload.code_name
  end

  should "return default site with nil subdomain" do
    default_site = Site.where(:subdomain => nil).first
    assert_equal default_site, Site.default
  end

  should "find site by subdomain when exists" do
    site = Factory(:site, :subdomain => "beer")
    assert_equal site, Site.find_for_domains(Site.default.domain, "beer")
  end

  should "return default site when no site was found" do
    assert_equal Site.default, Site.find_for_domains(Site.default.domain, "nonexisting")
  end

  should "return sites without default one" do
    @site.save!
    sites = Site.without_default.all
    assert sites.include?(@site)
    assert_false sites.include?(Site.default)
  end
end
