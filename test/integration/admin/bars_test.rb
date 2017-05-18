require "integration_test_helper"

class Admin::BarsTest < ActionController::IntegrationTest
  setup { sign_in :admin }

  context "with bars" do
    setup do
      Factory(:bar, :active => true, :pending => false, :name => "Saphire Bar")
      Factory(:bar, :active => false, :pending => false, :name => "Greenwich Bar")
      Factory(:bar, :active => false, :name => "Ruby Bar")
      click_link "Admin Backend"
    end
    
    should "display list of all active bars" do
      click_link "Bars"

      assert page.has_content?("Saphire Bar")
      assert !page.has_content?("Greenwich Bar")
      assert !page.has_content?("Ruby Bar")

      assert page.has_link? "Inactive"
      assert page.has_link? "Pending"
    end

    should "display list of all inactive bars" do
      click_link "Bars"
      click_link "Inactive"

      assert !page.has_content?("Saphire Bar")
      assert page.has_content?("Greenwich Bar")
      assert !page.has_content?("Ruby Bar")

      assert page.has_link? "Active"
      assert page.has_link? "Pending"
    end
  
    should "display list of all pending bars" do
      click_link "Bars"
      click_link "Pending"

      assert !page.has_content?("Saphire Bar")
      assert !page.has_content?("Greenwich Bar")
      assert page.has_content?("Ruby Bar")

      assert page.has_link? "Active"
      assert page.has_link? "Inactive"
    end
  end
  
  should "create bar with new city" do
    Factory(:country, :printable_name => "United States")
    visit new_admin_bar_path

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

  should "update bar" do
    bar = Factory(:bar, :active => true, :name => "Saphire Bar")

    click_link "Admin Backend"
    click_link "Bars"
    click_link "Saphire Bar"
    click_link "Edit This Bar"

    fill_in "Bar Name", :with => "Ruby Bar"
    click_button "Update Bar"

    assert page.has_content?("Bar updated!")
    assert_equal current_path, admin_bar_path(bar.reload)
  end
end
