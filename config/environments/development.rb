Buddybeers::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_view.debug_rjs             = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Set delivery method to :smtp, :sendmail or :test
  config.action_mailer.delivery_method = :test

  # Default host URL used in emails
  config.action_mailer.asset_host = 'http://drnk-dev.me:3000' 
  config.action_mailer.default_url_options = { :host => "drnk-dev.me:3000", :only_path => false }

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  SOCIAL_GOLD_OFFER_ID = "nvdo9h70w2i5eum8a9ra4og2b"
  SOCIAL_GOLD_URL = "api.sandbox.jambool.com"
  
  #TROPO_SMS_TOKEN = "0c395dafef11454d801bfabe07ebda63834019a7d8fa84535e47bbccfc237ada8192c1e9eacd8edc78727955"
  TROPO_SMS_TOKEN = "dd23aa93e71e0f4d829d59ff4826b31a243898f369203df551b664b8d3def1f8859a27349e8cd33d437c0c3a"
  #"0127533aefa7f04f845bbe2feda20b62da84ebc73eb732dccb0f198efa787a41bed4623cc82c4b215b0acb09"
  
  config.after_initialize do
      ActiveMerchant::Billing::Base.mode = :test
      paypal_options = {
        :login => APP_CONFIG['paypal_login'],
        :password => APP_CONFIG['paypal_password'],
        :signature => APP_CONFIG['paypal_signature']
      }
      ::EXPRESS_GATEWAY = ActiveMerchant::Billing::PaypalExpressGateway.new(paypal_options)
  end
end
