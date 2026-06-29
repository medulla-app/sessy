require "test_helper"

module Sessy
  class WebhooksControllerTest < ActionDispatch::IntegrationTest
    include SesPayloads

    setup { @source = Source.create!(name: "App") }

    def webhook_path(token) = "/sessy/webhooks/#{token}"

    test "notification ingests an event" do
      assert_difference -> { Event.count } => 1 do
        post webhook_path(@source.token),
          params: sns_notification(ses_delivery_event).to_json,
          headers: { "CONTENT_TYPE" => "application/json" }
      end
      assert_response :ok
    end

    test "subscription confirmation is auto-confirmed" do
      message = {
        "Type" => "SubscriptionConfirmation",
        "MessageId" => "sns-confirm",
        "Timestamp" => "2026-01-01T00:00:00.000Z",
        "SubscribeURL" => "https://sns.example.com/confirm"
      }

      confirmed = nil
      Net::HTTP.singleton_class.alias_method(:__test_get, :get)
      Net::HTTP.define_singleton_method(:get) { |uri| confirmed = uri.to_s; "" }

      post webhook_path(@source.token),
        params: message.to_json,
        headers: { "CONTENT_TYPE" => "application/json" }

      assert_response :ok
      assert_equal "https://sns.example.com/confirm", confirmed
    ensure
      Net::HTTP.singleton_class.alias_method(:get, :__test_get)
      Net::HTTP.singleton_class.send(:remove_method, :__test_get)
    end

    test "unknown token is not found" do
      post webhook_path("nope"),
        params: sns_notification(ses_delivery_event).to_json,
        headers: { "CONTENT_TYPE" => "application/json" }
      assert_response :not_found
    end
  end
end
