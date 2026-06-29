require "sessy/version"
require "sessy/engine"

module Sessy
  class << self
    # Controller the dashboard inherits from; set it to gate the dashboard
    # behind the host's auth. The webhook controller never inherits from this.
    attr_writer :parent_controller

    # Optional callable run as a before_action on dashboard requests.
    attr_accessor :authenticate

    def parent_controller
      @parent_controller ||= "ActionController::Base"
    end

    def configure
      yield self
    end
  end
end
