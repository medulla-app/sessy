require "sessy/version"
require "sessy/engine"

module Sessy
  class << self
    # Controller the dashboard inherits from; set it to gate the dashboard
    # behind the host's auth. The webhook controller never inherits from this.
    attr_writer :parent_controller

    # Optional callable run as a before_action on dashboard requests.
    attr_accessor :authenticate

    # When set, a webhook arriving with this exact token auto-creates its source
    # on first contact, so single-source deploys need no manual setup. Any other
    # unknown token still 404s, so the endpoint stays safe to expose.
    attr_accessor :auto_source_token

    attr_writer :auto_source_name

    # Retention applied to an auto-provisioned source (days). Without it the
    # source keeps every event forever, so set this to bound retention.
    attr_accessor :auto_source_retention_days

    def parent_controller
      @parent_controller ||= "ActionController::Base"
    end

    def auto_source_name
      @auto_source_name ||= "Default"
    end

    def configure
      yield self
    end
  end
end
