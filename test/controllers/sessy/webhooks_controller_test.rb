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

    test "the configured auto_source_token provisions a source on first contact" do
      Sessy.auto_source_token = "secret-token"
      Sessy.auto_source_retention_days = 90

      assert_difference -> { Source.count } => 1, -> { Event.count } => 1 do
        post webhook_path("secret-token"),
          params: sns_notification(ses_delivery_event).to_json,
          headers: { "CONTENT_TYPE" => "application/json" }
      end
      assert_response :ok
      source = Source.find_by(token: "secret-token")
      assert_equal "Default", source.name
      assert_equal 90, source.retention_days
    ensure
      Sessy.auto_source_token = nil
      Sessy.auto_source_retention_days = nil
    end

    test "an unknown token does not provision when it isn't the configured one" do
      Sessy.auto_source_token = "secret-token"

      assert_no_difference -> { Source.count } do
        post webhook_path("not-the-secret"),
          params: sns_notification(ses_delivery_event).to_json,
          headers: { "CONTENT_TYPE" => "application/json" }
      end
      assert_response :not_found
    ensure
      Sessy.auto_source_token = nil
    end
  end
end
