require 'test_helper'

class FacebookAppCredentialTest < ActiveSupport::TestCase
  
  should belong_to(:user)
  should belong_to(:site)
  should_not allow_value("").for(:access_token)
  should_not allow_value("").for(:app_id) 
  
end
