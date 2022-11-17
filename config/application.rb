require_relative "boot"
#require "active_storage/engine"
require "active_model/railtie" 
# And now the rest
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "active_job/railtie" # Only for Rails >= 4.2
require "action_cable/engine" # Only for Rails >= 5.0
require "sprockets/railtie" # Deprecated for Rails >= 7, so add it only if you're using it
require "rails/test_unit/railtie"
require 'rails/all'


# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Buscatrabajo
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Locales
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
    config.i18n.available_locales = [:ar]
    config.i18n.default_locale = :ar

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.

    config.generators do |g|
      g.orm :active_record
    end
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
