module Sessy
  # Inherits from ActionController::Base, not Sessy::ApplicationController, so the
  # host's dashboard auth never applies — auth here is the SNS signature + token.
  class WebhooksController < ActionController::Base
    # Shared so the signing-cert cache survives across requests (a fresh verifier
    # re-downloads the cert from AWS every time, ~600ms).
    SNS_MESSAGE_VERIFIER = Aws::SNS::MessageVerifier.new

    skip_forgery_protection
    before_action :set_source
    before_action :verify_sns_signature

    def create
      sns_message = JSON.parse(request.raw_post)

      case sns_message["Type"]
      when "SubscriptionConfirmation"
        confirm_subscription(sns_message["SubscribeURL"])
        head :ok
      when "Notification"
        handle_notification(sns_message)
        head :ok
      when "UnsubscribeConfirmation"
        Rails.logger.info("SNS Unsubscribe confirmation received")
        head :ok
      else
        Rails.logger.warn("Unknown SNS message type: #{sns_message["Type"]}")
        head :bad_request
      end
    rescue JSON::ParserError => e
      Rails.logger.error("Failed to parse SNS message: #{e.message}")
      head :bad_request
    end

    private

    def set_source
      @source = Source.for_webhook(params[:source_token])
      head :not_found unless @source
    end

    def handle_notification(sns_message)
      Webhook.process(sns_message, source: @source)
    end

    def confirm_subscription(subscribe_url)
      uri = URI.parse(subscribe_url)
      Net::HTTP.get(uri)
      Rails.logger.info("SNS subscription confirmed: #{subscribe_url}")
    rescue => e
      Rails.logger.error("Failed to confirm SNS subscription: #{e.message}")
    end

    def verify_sns_signature
      return true if Rails.env.local?

      message_body = request.raw_post

      unless SNS_MESSAGE_VERIFIER.authentic?(message_body)
        Rails.logger.error("SNS signature verification failed")
        head :forbidden
        return false
      end

      true
    rescue => e
      Rails.logger.error("SNS signature verification error: #{e.message}")
      head :forbidden
      false
    end
  end
end
