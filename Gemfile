source "http://rubygems.org"

gem "rails", "3.0.10"
gem "pg", "0.11.0"

gem "nested_form"
gem 'acts_as_tree'
gem "aws-s3"
gem 'carrierwave', "0.5.7"
gem "delayed_job", "~> 2.1"
gem "devise", "1.3.1" #:git => "git://github.com/plataformatec/devise.git"
gem 'fog'
gem "friendly_id", "4.0.0.beta11"
gem "geokit-rails3", "0.1.3"
gem 'gabba'
gem "gibbon", "0.1.7"
gem "haml", "3.0.25"
gem "heroku", "~> 1.20"
gem 'httparty', "0.7.7"
gem "json", "1.5.3"
gem "koala", "1.1.0rc2"
gem "money", "3.6.1"
gem "mobile-fu"
gem "activemerchant"
gem "oa-oauth", :require => "omniauth/oauth", :git => "git://github.com/morgoth/omniauth.git", :branch => "dynamic-providers"
gem "paperclip", "2.3.11"
gem 'prototype_legacy_helper', '0.0.0', :git => 'git://github.com/rails/prototype_legacy_helper.git'
gem 'puret'
gem 'rack-rewrite', '1.0.2'
gem "RedCloth", "4.2.7" # Textile
# gem "rmagick", :require => nil
gem "routing-filter", "0.2.3"
#gem "rqrcode", "0.3.3"
gem "qr4r"
gem 'sitemap_generator', '2.0.1.pre2'
#gem 'tolk', :git => 'git://github.com/szimek/tolk.git', :branch => 'rails3'
gem 'tropo-webapi-ruby', "0.1.10"
gem 'twilio-ruby'
gem 'twitter', :path => File.join(File.dirname(__FILE__), '/vendor/gems/twitter-1.2.0')
gem "uuid", "2.3.2"
gem 'whenever', "0.6.8"
gem "will_paginate", "3.0.pre2"

group :production, :staging do
  gem "rmagick", :require => nil
end

group :test do
  gem "test-unit", "2.3.0"
  gem "mocha", :require => false
  gem "shoulda", :require => false
  gem "factory_girl_rails", "1.0.1"
  gem "fakeweb"
  gem "capybara", "0.4.1.2", :require => false
  gem "launchy"
end

group :development do
  gem "rails3-generators"
  gem "heroku_san", "1.1.0"
  gem "taps"
  gem 'railroady'
end

group :test, :development do
  gem "fakeweb"
  gem "ruby-debug", :platform => "ruby_18"
  gem "ruby-debug19", :platform => "ruby_19", :require => "ruby-debug"
end
