module FacebookHelper
  
  def host_via_subdomain
    host = ""
    if current_site.subdomain.present?
      host += "#{current_site.subdomain}."
    end
    if Rails.env.production?
      host += "buddybeers.com"
    elsif Rails.env.staging?
      host += "drnk.me"
    elsif Rails.env.development?
      host += "drnk-dev.me:3000"
    else
      host += "buddybeers.com"
    end
    return host
  end
  
  def facebook_login_button
    link_to t("sessions.new.connect_with_facebook"), "#{request.ssl? ? "https://" : "http://"}#{host_via_subdomain}#{user_omniauth_authorize_path(:facebook)}", :rel => "nofollow", :title => t("sessions.new.connect_with_facebook"), :class => I18n.locale.to_s == "de" ? "de" : "en"
  end
  
  def facebook_locale(locale)
    case locale
    when "en"
      "en_US"
    when "de"
      "de_DE"
    when "nl"
      "nl_NL"
    when "fr"
      "fr_FR"  
    when "th"
      "th_TH"
    when "it"
      "it_IT"
    end
  end
  
  def facebook_app_id
    current_site.facebook_app_id.present? ? current_site.facebook_app_id : APP_CONFIG['fb_app_id']
  end
  
  def facebook_app_secret
    current_site.facebook_app_secret.present? ? current_site.facebook_app_secret : APP_CONFIG['fb_app_secret_id']
  end
  
  def build_facebook_url(path)
    [(request.ssl? ? "https://" : "http://"), (current_site.subdomain ? "#{current_site.subdomain}." : ""), (Rails.env.development? ? "drnk-dev.me:3000" : "drnk.me"), path].join()
  end
end
