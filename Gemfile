# frozen_string_literal: true

source 'https://rubygems.org'

# Declare your gem's dependencies in simple_drilldown.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec path: __dir__

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# To use a debugger
# gem 'byebug', group: [:development, :test]

group :development, :test do
  gem 'activerecord-jdbcsqlite3-adapter', '>=71', platform: :jruby
  gem 'rubocop-capybara', require: false
  gem 'sqlite3', '<2', platform: :ruby
end

group :test do
  gem 'capybara'
  gem 'net-smtp'
  gem 'paranoia'
  gem 'puma'
  gem 'rubocop'
  gem 'selenium-webdriver'
  gem 'sprockets-rails'
  gem 'webdrivers'
end
