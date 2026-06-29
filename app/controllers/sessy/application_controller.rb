module Sessy
  class ApplicationController < Sessy.parent_controller.constantize
    include Pagy::Method

    before_action :authenticate_sessy_request

    private

    def authenticate_sessy_request
      instance_exec(&Sessy.authenticate) if Sessy.authenticate
    end
  end
end
