#!/usr/bin/ruby

source 'https://rubygems.org'

gem 'rails', '3.2.6'
gem "mongoid", "~> 3.0.0" # database
gem "devise"              # authentication
gem "cancan"              # authorization
gem "twitter-bootstrap-rails" # UI basic components

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

group :development, :test do
  gem "rspec-rails"
end

group :test do
  gem "database_cleaner"
  gem "factory_girl_rails"
  gem "mongoid-rspec"
end
