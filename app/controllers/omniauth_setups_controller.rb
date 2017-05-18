class OmniauthSetupsController < ApplicationController
  def facebook
    logger.debug("!!!!!!!!!!!!!! #{request.env['omniauth.strategy'].client_options.inspect}")
    request.env['omniauth.strategy'].client_id = current_site.facebook_app_id
    request.env['omniauth.strategy'].client_secret = current_site.facebook_app_secret
    request.env['omniauth.strategy'].options[:scope] = current_site.facebook_app_scope
    #logger.debug("!!!!!!!!!!!!!!!!!!!! #{request.env['omniauth.origin'].inspect}")
    # if current_site.subdomain
    #   request.env['omniauth.strategy'].options.merge!({:full_host => "http://#{current_site.subdomain}.buddybeers.com"})
    # end
    # logger.debug("!!!!!!!!!!!!!! #{request.env['omniauth.strategy'].inspect}")
    render :text => "Setup complete.", :status => 404
  end
end
