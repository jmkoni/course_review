# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.3'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'puma', '~> 4.0'
gem 'rails', '~> 5.2.3'

# Database and Authentication
gem 'bcrypt', '~> 3.1.13'
gem 'cancancan'
gem 'devise'
gem 'pg', '>= 0.18', '< 2.0'

# Assets
gem 'bootstrap'
gem 'execjs'
gem 'filterrific'
gem 'jbuilder', '~> 2.5'
gem 'jquery-rails'
gem 'kaminari'
gem 'mini_racer'
gem 'sass-rails', '~> 5.0'
gem 'sorbet-runtime'
gem 'turbolinks', '~> 5'
gem 'uglifier', '>= 1.3.0'

# Documentation
gem 'simplecov-formatter-badge', require: false
gem 'yard'

# Monitoring
gem 'skylight'

# Seeds
gem 'faker'

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
  gem 'rubocop-rails'

  # Development Gems
  gem 'annotate'
  gem 'awesome_print'
  gem 'better_errors'
  gem 'bullet'
  gem 'factory_bot_rails'
  gem 'foreman'
  gem 'launchy'
end

group :development do
  gem 'irb', require: false
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'sorbet'
  gem 'sorbet-rails'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'

  # Profiling
  gem 'rack-mini-profiler'
  # For memory profiling
  gem 'memory_profiler'

  # For call-stack profiling flamegraphs
  gem 'flamegraph'
  gem 'stackprof'

  # Scrapers
  gem 'httparty'
  gem 'nokogiri'
end

group :test do
  gem 'capybara', '>= 2.15'
  gem 'codecov', require: false
  gem 'database_cleaner'
  gem 'rails-controller-testing'
  gem 'rspec'
  gem 'rspec-rails'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers'
  gem 'simplecov'
end
