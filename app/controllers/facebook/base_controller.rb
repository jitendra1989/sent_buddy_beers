class Facebook::BaseController < ApplicationController
  
  require 'net/http'
  
  before_filter :set_p3p, :initialize_fb_oauth
  
  layout 'facebook'
  
private

  def initialize_fb_oauth
    @oauth = Koala::Facebook::OAuth.new(current_site.facebook_app_id, current_site.facebook_app_secret, "http://apps.facebook.com/#{current_site.facebook_app_url}/")
    @oauth_url = @oauth.url_for_oauth_code(:permissions => ["email", "publish_stream"])
  end
  
  def find_fb_user_and_sign_in
    # logger.debug("|||||||||||||||||||| Signed request: #{request.POST['signed_request']} ||||||||||||||||||||")
    
    unless user_signed_in?
      logger.debug("!!!!!!!!!!!!!! No user is signed in")
      
      # AUTHORIZE USER FROM SIGNED REQUEST
      if params[:signed_request] 
        signed_request = @oauth.parse_signed_request(params[:signed_request])
        logger.debug("!!!!!!!!!!!!!! signed_request: #{signed_request.inspect}")
    
        # IF THE USER IS AUTHORIZED
        if signed_request['user_id']
          token = signed_request['oauth_token']
          uid = "me"
        end
      else
        fb_cookie = @oauth.get_user_info_from_cookies(cookies) 
        logger.debug("!!!!!!!!!!!!!! cookie: #{fb_cookie.inspect}")
      
        # IF THE USER IS AUTHORIZED
        if fb_cookie and fb_cookie["access_token"]
          logger.debug("!!!!!!!!!!!!!! cookie exists")
          token = fb_cookie['access_token']
          logger.debug("!!!!!!!!!!!!!! token: #{token}")
          uid = fb_cookie["uid"]
          logger.debug("!!!!!!!!!!!!!! uid: #{uid}")
        end
      end
    
      if (signed_request and signed_request['user_id']) or (fb_cookie and fb_cookie["access_token"])
        @graph = Koala::Facebook::GraphAPI.new(token)
        logger.debug("!!!!!!!!!!!!!! graph: #{@graph.inspect}")
        @fb_user = @graph.get_object(uid)
        logger.debug("!!!!!!!!!!!!!! me: #{@fb_user.inspect}")
        data = {"extra" => {"user_hash" => @fb_user}, "credentials" => {"token" => token}}
        user = User.find_for_facebook_oauth(data, current_site)
        sign_in(user)
      end
    end
    return
  rescue Koala::Facebook::APIError
    current_user = nil
    logger.debug("!!!!!!!!!!!!!! API error. Session probably timed out.")
    render 'facebook/home/redirect_to_oauth'
    return
  end
  
  def require_fb_user
    find_fb_user_and_sign_in
    respond_to do |format|
      format.html do
        unless current_user
          render 'facebook/home/redirect_to_oauth'
          return
        else
          logger.debug("!!!!!!!!!!!!!! user is signed in #{current_user}")
          return true
        end
      end
      format.pdf do
        render :nothing
        return
      end
    end
  rescue Koala::Facebook::APIError
    respond_to do |format|
      format.html do
        current_user = nil
        logger.debug("!!!!!!!!!!!!!! API error. Session probably timed out.")
        render 'facebook/home/redirect_to_oauth'
        return
      end
      format.pdf do
        render :nothing
        return
      end
    end
  end
  
  def initialize_fb_graph
    @graph = @graph || Koala::Facebook::GraphAPI.new(current_user.fb_access_token_for(current_site))
    logger.debug("!!!!!!!!!!!!!! graph #{@graph.inspect}")
    @fb_user = @fb_user || @graph.get_object('me')
    logger.debug("!!!!!!!!!!!!!!fb_user #{@fb_user.inspect}")
    @picture = @graph.get_picture('me')
    # TODO: Add batch here later
  rescue Koala::Facebook::APIError
    logger.debug("!!!!!!!!!!!!!! API error. Session probably timed out. Attempting to refresh session.")
    refresh_fb_session
  end
  
  def refresh_fb_session
    fb_cookie = @oauth.get_user_info_from_cookies(cookies)
    logger.debug("!!!!!!!!!!!!!! cookie #{fb_cookie.inspect}")
    if fb_cookie
      logger.debug("!!!!!!!!!!!!!! updating user cookie")
      app_cred = FacebookAppCredential.find_by_user_id_and_site_id_and_app_id(current_user.id, current_site.id, current_site.facebook_app_id)
      app_cred.update_attribute(:access_token => fb_cookie['access_token'])
      return true
    else
      render 'facebook/home/redirect_to_oauth'
      return
    end
  end
  
  def get_fb_friends
    @friends = @graph.get_connections('me', 'friends')
    @friends.sort! { |a,b| a['name'].downcase <=> b['name'].downcase }
    logger.debug("!!!!!!!!!!!!!! friends: #{@friends.inspect}")
  rescue Koala::Facebook::APIError
    refresh_fb_session      
  end
end
