require "integration_test_helper"

class SiteAdmin::BarsTest < ActionController::IntegrationTest
  setup do
    @site = Factory(:site, :name => "Pilsner")
    @site_admin = Factory(:site_admin, :sites => [ @site ])
    sign_in @site_admin
    click_link "Admin Backend"
  end
  context "with bars" do
    
    setup do
      Factory(:bar, :active => true, :pending => false, :sites => [ @site ], :name => "Saphire Bar")
      Factory(:bar, :active => true, :pending => false, :name => "8mm Bar")
      Factory(:bar, :active => false, :pending => false, :sites => [ @site ], :name => "Greenwich Bar")
      Factory(:bar, :active => false, :sites => [ @site ], :name => "Walla Bar")
    end
    
    should "display list of all active bars associated with site admin's sites" do
      click_link "Bars"

      assert page.has_content?("Saphire Bar")
      assert !page.has_content?("8mm Bar")
      assert !page.has_content?("Greenwich Bar")

      assert page.has_link? "Inactive"
      assert page.has_link? "Pending"
    end

    should "display list of all inactive bars associated with site admin's sites" do
      click_link "Bars"
      click_link "Inactive"

      assert !page.has_content?("Saphire Bar")
      assert !page.has_content?("8mm Bar")
      assert page.has_content?("Greenwich Bar")

      assert page.has_link? "Active"
      assert page.has_link? "Pending"
    end
  
    should "display list of all pending bars associated with site admin's sites" do
      click_link "Bars"
      click_link "Pending"

      assert !page.has_content?("Saphire Bar")
      assert !page.has_content?("8mm Bar")
      assert !page.has_content?("Greenwich Bar")
      assert page.has_content?("Walla Bar")

      assert page.has_link? "Active"
      assert page.has_link? "Inactive"
    end
  end

  should "create bar with new city" do
    Factory(:country, :printable_name => "United States")
    visit new_site_admin_bar_path

    check "Pilsner"
    fill_in "Bar Name:", :with => "Moe's Tavern"
    fill_in "Address:", :with => "Springfield"
    check "Active?"
    select "United States", :from => "Country:"
    fill_in "new_city_name", :with => "Springfield"
    click_button "Create Bar"

    bar = Bar.where(:name => "Moe's Tavern").first
    assert bar
    assert_equal "Springfield", bar.city.name
    assert !bar.pending
  end

  should "update a bar" do
    bar = Factory(:bar, :active => true, :sites => [ @site ], :name => "Saphire Bar")

    click_link "Bars"
    click_link "Saphire Bar"
    click_link "Edit This Bar"

    fill_in "Bar Name", :with => "Ruby Bar"
    click_button "Update Bar"

    assert page.has_content?("Bar updated!")
    assert_equal current_path, site_admin_bar_path(bar.reload)
  end

  should "redeem outstanding vouchers" do
    bar = Factory(:bar, :active => true, :sites => [ @site ], :name => "Saphire Bar")

    # Prepare redeemable vouchers
    price = Factory(:price, :bar => bar)
    voucher_list = Factory(:voucher_list, :bar => bar, :cents => price.cents)
    iou = Factory(:iou, :site => @site, :bar => bar, :price => price, :quantity => 2)
    iou.paid!

    voucher_1 = iou.vouchers[0]
    voucher_2 = iou.vouchers[1]

    click_link "Bars"
    click_link "Saphire Bar"

    within("#vouchers form.edit_bar") do
      assert_match voucher_1.code, find(:xpath, './/li[1]').text
      assert_match voucher_2.code, find(:xpath, './/li[2]').text
    end

    within("#vouchers form.edit_bar") do
      fill_in voucher_1.code, :with => voucher_1.redemption_token
      fill_in voucher_2.code, :with => "fake token"
    end

    click_button "Update"

    within("#vouchers form.edit_bar") do
      assert_match voucher_2.code, find(:xpath, './/li[1]').text
    end

    assert voucher_1.reload.redeemed?
    assert !voucher_2.reload.redeemed?
  end
end
