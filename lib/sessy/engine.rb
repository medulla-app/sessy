require "propshaft"
require "importmap-rails"
require "turbo-rails"
require "stimulus-rails"
require "local_time"
require "pagy"
require "aws-sdk-sns"

module Sessy
  class Engine < ::Rails::Engine
    isolate_namespace Sessy

    initializer "sessy.assets" do |app|
      if app.config.respond_to?(:assets)
        app.config.assets.paths << root.join("app/javascript")
        app.config.assets.paths << root.join("vendor/javascript")
      end
    end

    # Dashboard JS needs importmap-rails in the host (see README).
    initializer "sessy.importmap", before: "importmap" do |app|
      if app.config.respond_to?(:importmap)
        app.config.importmap.paths << root.join("config/importmap.rb")
        app.config.importmap.cache_sweepers << root.join("app/javascript")
      end
    end
  end
end
