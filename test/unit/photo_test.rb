require 'test_helper'

class PhotoTest < ActiveSupport::TestCase

  should belong_to(:gallery)
  
  should have_attached_file(:photo)
  
  # should have_attached_file(:photo)
  # should validate_attachment_presence(:photo)
  # should validate_attachment_size(:photo)

  # can't get these to work, even with the hack:
  # to deal with: http://github.com/thoughtbot/paperclip/issues/issue/59
  # add from: http://gist.github.com/149244

  # This test below actually calls AWS (6 times!) so only run it if something is wrong.
  # context "a full gallery" do
  #   setup do
  #     @bar = Factory(:bar)
  #     5.times{ Factory(:photo, :gallery_id => @bar.gallery(true).id) }
  #   end
  #
  #   should "not allow more photos" do
  #     @photo = Photo.new(Factory.attributes_for(:photo, :gallery_id => @bar.gallery(true).id) )
  #     @photo.save
  #     assert @photo.errors.present?
  #     assert @photo.new_record?
  #   end
  # end

end
