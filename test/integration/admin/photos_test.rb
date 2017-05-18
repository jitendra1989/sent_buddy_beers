require "integration_test_helper"

class Admin::PhotosTest < ActionController::IntegrationTest
  setup do
    @bar = Factory(:bar)
    sign_in :admin
  end

  should "add new photo to given bar" do
    visit new_admin_bar_photo_path(@bar)

    attach_file "Photo", test_file_path("photo.png")
    fill_in "Title", :with => "Moe's"
    fill_in "Description", :with => "Moe's Tavern"
    click_button "Add"

    assert Photo.exists?(:title => "Moe's", :gallery_id => @bar.reload.gallery.id)
  end

  should "update existing photo" do
    @photo = Factory(:photo, :gallery => @bar.reload.gallery, :title => "Moe's")

    visit edit_admin_bar_photo_path(@bar, @photo)

    fill_in "Title", :with => "Moe's Tavern"
    click_button "Update"

    assert_equal "Moe's Tavern", @photo.reload.title
  end

  should "delete existing photo" do
    @photo = Factory(:photo, :gallery => @bar.reload.gallery, :title => "Moe's")

    visit admin_bar_photos_path(@bar)

    click_link "Delete"

    assert_false Photo.exists?(:title => "Moe's", :gallery_id => @bar.reload.gallery.id)
  end
end
