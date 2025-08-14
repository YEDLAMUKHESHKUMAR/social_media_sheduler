source "https://rubygems.org"

gem "rails", "~> 7.2.2"
gem "sprockets-rails", "~> 3.4"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"

gem "redis", ">= 4.0.1"
gem "bcrypt", "~> 3.1.7"

gem "omniauth-linkedin-oauth2", "~> 1.0"

gem "oauth", "~> 1.1"
gem "omniauth", "~> 2.1"
gem "omniauth-twitter", "~> 1.4"
gem "omniauth-rails_csrf_protection", "~> 1.0"
gem "twitter", "~> 7.0"


gem "sidekiq", "~> 7.0"
gem "httparty", "~> 0.21"
gem "dotenv-rails"

gem "tzinfo-data", platforms: %i[ mswin mswin64 mingw x64_mingw jruby ]
gem "bootsnap", require: false

group :development, :test do
  gem "debug", platforms: %i[ mri mswin mswin64 mingw x64_mingw ], require: "debug/prelude"
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
end

group :development do
  gem "web-console"
  gem "error_highlight", ">= 0.4.0", platforms: [ :ruby ]
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end
