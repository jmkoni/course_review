# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.3'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'puma', '~> 4.3'
gem 'rails', '~> 6.0.2'

# Database and Authentication
gem 'bcrypt', '~> 3.1.13'
gem 'cancancan'
gem 'devise'
gem 'pg', '>= 0.18', '< 2.0'

# Assets
gem 'bootstrap'
gem 'execjs'
gem 'filterrific'
gem 'jbuilder', '~> 2.10'
gem 'jquery-rails'
gem 'kaminari'
gem 'mini_racer'
gem 'sass-rails', '~> 6.0'
gem 'turbolinks', '~> 5'
gem 'uglifier', '>= 1.3.0'

# Email
gem 'sendgrid-ruby'

# Documentation
gem 'simplecov-formatter-badge', require: false
gem 'yard', '>= 0.9.20'

# Monitoring
gem 'skylight'

# Seeds
gem 'faker'

group :development, :test do
  # Debugging Gems
  gem 'binding_of_caller'
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'jazz_fingers'
  gem 'pry'
  gem 'pry-byebug'
  gem 'pry-remote'

  # Auditing Gems
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false

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
  gem 'listen', '>= 3.0.5', '< 3.3'
  gem 'rails-erd'
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

  # For email - https://github.com/ryanb/letter_opener
  # gem 'letter_opener'
end

group :test do
  gem 'capybara', '>= 2.15'
  gem 'codecov', require: false
  gem 'rails-controller-testing'
  gem 'rspec'
  gem 'rspec-rails', '~> 4.0.0.beta4'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers'
  gem 'simplecov'
end
