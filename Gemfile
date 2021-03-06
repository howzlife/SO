source 'https://rubygems.org'

#ruby version
ruby '2.1.4'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.1.6'
#Use Bootstrap
gem 'bootstrap-sass', '~> 3.3.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.3'
#Autoprefixer adds the proper vendor prefixes to your CSS code when it is compiled.
gem 'autoprefixer-rails'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer',  platforms: :ruby
# Add Haml
gem 'haml-rails'
# Support Mongodb
gem 'mongoid'
# Add simple form
#add BSON support
gem 'bson_ext'
#for simple forms
gem 'simple_form'
# Add paranoia so we can recover things that are deleted
gem 'mongoid_paranoia'
# for testing and DB cleaner
gem 'mongoid-tree'
#Include 'rails_12factor' gem to enable all platform features
#See https://devcenter.heroku.com/articles/rails-integration-gems for more information.
gem 'rails_12factor'
#add devise
gem 'devise'

# Use jquery as the JavaScript library
gem 'jquery-rails'
# jquery UI, for calendars, datepicker, and other neat tidbits
gem 'jquery-ui-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0',          group: :doc

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
gem 'spring',        group: :development

#add figaro to ensure secure ENV config variables that can't be accidently git commited
gem "figaro"

#generate PDF's using heroku add on
gem 'doc_raptor'

#mailchimp api for adding confirmed signups to mailchimp
gem 'mailchimp-api', require: 'mailchimp'

gem 'kaminari'

#aws
gem 'aws-sdk'

#gem factory girl, to use as fixtures for testing
gem "factory_girl_rails", "~> 4.0"

#warden gem for testing authentication
gem "warden"

# capistrano gem to set up staging environment. All code will be pushed there before being put into production
gem 'capistrano', '~> 3.3.0'

# stripe gem to accept payments
gem 'stripe', :git => 'https://github.com/stripe/stripe-ruby'

# phaxio gem for sending faxes
gem 'phaxio'

# responder gem to set response message, and clean up my controllers!
gem 'responders'

# spring gem to speed up rspec tests
gem 'spring-commands-rspec', group: :development

# for mongoid enums, for plans and max amount of po's
gem 'mongoid-enum'

# missing dependency
gem 'mime-types'

# http interactions
gem 'typhoeus'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]


# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'therubyracer', :platform=>:ruby
end

#Gems used for devlopment and testing environment
group :development, :test do
  gem 'rspec-rails'
  gem 'better_errors'
  gem 'capybara'
  gem 'byebug'
  gem 'vcr'
end

group :test do
  gem 'cucumber-rails', :require => false
  gem 'database_cleaner'
end

