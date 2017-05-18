require 'test_helper'

class GalleryTest < ActiveSupport::TestCase
  should have_many(:photos)
  should belong_to(:attachable)
end
