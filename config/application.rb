require_relative 'boot'

require "rails"
require "active_job/railtie"
require "active_model/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"
require "rails/test_unit/railtie"
require 'net/http'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module DataCollector
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified
    # here. Application configuration should go into files in
    # config/initializers -- all .rb files in that directory are automatically
    # loaded.
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '*', :headers => :any, :methods => [:get, :post, :options]
      end
    end
  end
end
