source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.3'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.3'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'puma', '~> 3.11'

# Database and Authentication
gem 'bcrypt', '~> 3.1.7'
gem 'cancancan'
gem 'devise'
gem 'pg', '>= 0.18', '< 2.0'

# Assets
gem 'bootstrap'
gem 'execjs'
gem 'jbuilder', '~> 2.5'
gem 'jquery-rails'
gem "mini_racer"
gem 'sass-rails', '~> 5.0'
gem 'turbolinks', '~> 5'
gem 'uglifier', '>= 1.3.0'

# Documentation
gem 'yard'

group :development, :test do
  # Debugging Gems
  gem 'binding_of_caller'
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'pry'
  gem 'pry-byebug'
  gem 'pry-remote'

  # Auditing Gems
  gem 'rubocop'
  gem 'rubocop-performance'

  # Development Gems
  gem 'annotate'
  gem 'awesome_print'
  gem 'better_errors'
  gem 'bullet'
  gem 'factory_bot_rails'
  gem 'foreman'
  gem 'launchy'

  # Seeds
  gem 'faker'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'
end

group :test do
  gem 'capybara', '>= 2.15'
  gem 'chromedriver-helper'
  gem 'rspec'
  gem 'rspec-rails'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers'
  gem 'simplecov'
end
