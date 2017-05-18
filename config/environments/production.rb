Buddybeers::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Specifies the header that your server uses for sending files
  config.action_dispatch.x_sendfile_header = "X-Sendfile"

  # For nginx:
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Disable Rails's static asset server
  # In production, Apache or nginx will already do this
  config.serve_static_assets = false

  # Enable serving of images, stylesheets, and javascripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"
  config.action_controller.asset_host = "https://assets.buddybeers.com"
  # config.action_controller.asset_host = AssetHostingWithMinimumSsl.new(
  #     "http://assets.buddybeers.com", "https://assets.buddybeers.com"
  #   )
  
  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  # Default host URL used in emails
  
  config.action_mailer.asset_host = "http://assets.buddybeers.com"
  config.action_mailer.default_url_options = { :host => "buddybeers.com", :only_path => false }

  SOCIAL_GOLD_OFFER_ID = "erxgogle2ud85bkq5hjxalz7s"
  SOCIAL_GOLD_URL = "api.jambool.com"

  # Paypal API credentials
  # Credential  API Signature
  # API Username  travisjtodd_api1.me.com
  # API Password  HL7GNEZ8FVX786BA
  # Signature   AFcWxV21C7fd0v3bYYYRCpSSRl31AsI19R84BfzIAqNUHXRw0NfMh1DQ
  # Request Date  Mar 8, 2010 08:23:09 PST
  
  #TROPO_SMS_TOKEN = "0127b2c457a0884faab839a1e433aa59774bb68e92691e9ebd0267fa7fd18b6786419c8aa5ffb934378d6b57"
  TROPO_SMS_TOKEN = "8de7fd367b05f3478939ce61afbfc8172732a4974000f27f2ac8c3fb2f972417babdc16135bf76d529a8eb39"
  
  config.after_initialize do
    ActiveMerchant::Billing::Base.mode = :production
    paypal_options = {
      :login => APP_CONFIG['paypal_login'],
      :password => APP_CONFIG['paypal_password'],
      :signature => APP_CONFIG['paypal_signature']
    }
    ::EXPRESS_GATEWAY = ActiveMerchant::Billing::PaypalExpressGateway.new(paypal_options)
  end
end
