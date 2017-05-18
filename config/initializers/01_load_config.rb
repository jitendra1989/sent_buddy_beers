unless defined?(APP_CONFIG)
  rails_root = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../..'
  rails_env = Rails.env || 'development'

  app_config = YAML.load_file(rails_root + '/config/config.yml')
  APP_CONFIG = app_config[rails_env]
end
