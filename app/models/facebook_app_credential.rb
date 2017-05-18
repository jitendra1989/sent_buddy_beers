class FacebookAppCredential < ActiveRecord::Base
  
  # Facebook access_tokens are granted only for a specific user for a specific facebook app.
  # Since we're running multiple apps (one for each site) we need to store multiple access_tokens
  # This model allows us to do this.
  
  belongs_to :user
  belongs_to :site
  
  validates :access_token, :presence => true
  validates :app_id, :presence => true
  
end
