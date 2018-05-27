require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)

module QuasiCase
  class Application < Rails::Application
    config.load_defaults 5.1

    config.generators do |g|
      g.javascripts false
      g.stylesheets false
      g.helper false

      g.test_framework :rspec,
        view_specs: false,
        helper_specs: false,
        routing_specs: false,
        request_specs: false
    end

    config.time_zone = 'Tokyo'
    config.active_record.default_timezone = :local

    config.rack_dev_mark.enable = !Rails.env.production?

    config.autoload_paths += Dir["#{config.root}/app/validators"]
    config.autoload_paths += Dir["#{config.root}/app/callbacks"]
  end
end
