# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  helper :all
  helper_method :current_site, :admin_signed_in?, :site_admin_signed_in?, :affiliate_signed_in?, :corporate_signed_in?
  protect_from_forgery

  before_filter :authenticate, :set_current_site, :set_locale, :ensure_correct_subdomain, :set_view_path
  
  rescue_from ActionController::RoutingError do
    render_404
  end
  
  
   
  def default_url_options(options={})
    {:locale => I18n.locale}
  end

  def current_site
    Thread.current[:current_site]
  end

  private

  def set_current_site
    # Get and set the Site from the domain and subdomain (if present)

    # This is borking the bar signup
    # if current_site and current_site.domain == request.domain and current_site.subdomain == request.subdomains.last
    #       current_site
    #     else
    #       Thread.current[:current_site] = Site.find_for_domains(request.domain, request.subdomains.last)
    #     end

    Thread.current[:current_site] = Site.find_for_domains(request.domain, request.subdomains.last)
    render_404 and return unless Thread.current[:current_site]
  end

  def set_view_path
    site_pathset = CustomViewPaths.pathsets[current_site.code_name]
    self.prepend_view_path(site_pathset)
    ActionMailer::Base.prepend_view_path(site_pathset)
  end

  def ensure_correct_subdomain


    # logger.debug("!!!!!! domain #{request.domain} !!!!!!!")
    # logger.debug("!!!!!! domain #{Site.default.domain} !!!!!!!")
    # logger.debug("!!!!!! domain #{request.subdomains.last} !!!!!!!")
    # logger.debug("!!!!!! domain #{current_site.subdomain} !!!!!!!")

    # if the domain requested is the domain for the default site (buddybeers.com) but the subdomain is not the current site's subdomain
    # if request.domain == Site.default.domain && request.subdomains.last != current_site.subdomain
    #   redirect_to root_url(:host => with_subdomain(nil))
    # end
  end

  def set_locale
    locale = params[:locale] || current_user.try(:language) || locale_from_browser || I18n.default_locale
    I18n.locale = locale.to_s
    if user_signed_in?
      current_user.language = I18n.locale.to_s
      current_user.save if current_user.language_changed?
    end
  end

  def locale_from_browser
    if request.env['HTTP_ACCEPT_LANGUAGE'].present?
      browser_locale = request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
      browser_locale if I18n.available_locales.map(&:to_s).include?(browser_locale)
    end
  end

  def authenticate
=begin
    unless request.path == '/en/pages/privacy'
      authenticate_or_request_with_http_basic do |username, password|
        username == "einbier" && password == "vonfass"
      end if request.get? and Rails.env.staging?
    end
=end
  end

  def require_admin
    deny_access unless admin_signed_in?
  end

  def require_site_admin
    deny_access unless site_admin_signed_in?
  end

  def require_affiliate
    deny_access unless affiliate_signed_in?
  end
  
  def require_corporate
    deny_access unless corporate_signed_in?
  end

  def require_bro
    deny_access unless bro_signed_in?
  end

  def require_no_user
    if current_user
      store_location
      #flash[:error] = t("global.require_no_user")
      redirect_to new_iou_url
      return false
    end
  end

  def deny_access
    store_location
    flash[:error] = t("global.access_denied")
    redirect_to root_url
    return false
  end

  def admin_signed_in?
    current_user and current_user.admin?
  end

  def site_admin_signed_in?
    current_user and current_user.site_admin?
  end

  def bro_signed_in?
    current_user and current_user.bro?
  end

  def affiliate_signed_in?
    current_user and current_user.affiliate?
  end
  
  def corporate_signed_in?
    @current_corporate ||= Corporate.find(session[:corporate_id]) if session[:corporate_id]
  end

  def store_location
    session[:return_to] = request.fullpath
  end

  def find_or_create_beer(params)
    @beer = Beer.find_by_name_and_brand_id(params[:name], params[:brand_id])
    if @beer.nil?
      @beer = Beer.new(params)
      @beer.save
    end
  end

  # Called from bars_controller and prices_controller
  def redirect_if_active_or_not_pending
    if @bar.active or !@bar.pending
      flash[:error] = t("global.access_denied")
      redirect_to root_url
    end
  end

  def with_subdomain(subdomain)
    subdomain ||= ""
    subdomain += "." unless subdomain.empty?
    [subdomain, request.domain, request.port_string].join
  end

  def render_404
    respond_to do |format|
      format.html { render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => 'new_application' }
      format.any  { head :not_found }
    end
  end

  #facebook stuff

  def set_p3p
    response.headers["P3P"]='CP="IDC DSP COR CURa ADMa OUR IND PHY ONL COM STA"'
  end

  def post_to_facebook(order)
    if order.sender.facebook_user? and order.sender.has_fb_post_permissions_for?(current_site)
      @graph = Koala::Facebook::GraphAPI.new(order.sender.fb_access_token_for(current_site))
      if order.recipient_facebook_uid.present?
        # Post to wall and tag a friend
        order.update_attribute(:posted_to_friends_facebook_wall_at, DateTime.now()) if @graph.put_wall_post(I18n.t("facebook.orders.show.social_spread.fb_status", :beer => [order.quantity, order.price_name].join(" "), :bar => order.bar.name, :city => order.bar.city.name, :memo => order.memo, :link => app_download_url, :recipient_fb_id => order.recipient_facebook_uid.to_s),
                                    {  :name => I18n.t("bars.show.title", :bar => order.bar.name, :city => order.bar.city.name, :country => order.bar.country.printable_name),
                                       :link => bar_url(order.bar), :picture => order.bar.fb_image_url, :caption => bar_url(order.bar),
                                       :description => order.bar.description.present? ? order.bar.description.gsub(/\n/," ").gsub(/\r/," ") : I18n.t("layouts.meta.description").gsub(/\n/," ").gsub(/\r/," "),
                                       :actions => {:name => I18n.t("facebook.orders.show.social_spread.fb_action"), :link => app_download_url}
                                    })
      else
        # Post to my wall
        order.update_attribute(:posted_to_facebook_wall_at, DateTime.now()) if @graph.put_wall_post(I18n.t("facebook.orders.show.social_spread.my_fb_status", :recipient => order.recipient_name, :beer => [order.quantity, order.price_name].join(" "), :bar => order.bar.name, :city => order.bar.city.name, :memo => order.memo),
                            {  :name => I18n.t("bars.show.title", :bar => order.bar.name, :city => order.bar.city.name, :country => order.bar.country.printable_name),
                               :link => bar_url(order.bar), :picture => order.bar.fb_image_url, :caption => bar_url(order.bar),
                               :description => order.bar.description.present? ? order.bar.description.gsub(/\n/," ").gsub(/\r/," ") : I18n.t("layouts.meta.description").gsub(/\n/," ").gsub(/\r/," "),
                               :actions => {:name => I18n.t("facebook.orders.show.social_spread.fb_action"), :link => app_download_url}
                            })
      end
  end
  rescue Koala::Facebook::APIError
    logger.debug("There was an error posting to the users' wall. Likely due to a timed out session.")
    return true
  rescue ActiveRecord::StaleObjectError
    logger.debug("There was an error updating the iou. Stale as shit, bro.")
    return true
  end

  # These two actions are for using helpers in the controllers.
  # For example help.pluralize(1, "beer")
  # http://snippets.dzone.com/posts/show/1799
  def help
    Helper.instance
  end

  class Helper
    include Singleton
    include ActionView::Helpers::TextHelper
  end
end
