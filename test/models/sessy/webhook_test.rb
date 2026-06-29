require "test_helper"

module Sessy
  class WebhookTest < ActiveSupport::TestCase
    include SesPayloads

    setup { @source = Source.create!(name: "App") }

    test "process ingests events and marks the webhook processed" do
      message = sns_notification(ses_delivery_event)

      assert_difference -> { Webhook.count } => 1, -> { Event.count } => 1 do
        Webhook.process(message, source: @source)
      end

      assert Webhook.last.processed_at?
    end

    test "process is idempotent on the SNS MessageId" do
      message = sns_notification(ses_delivery_event, message_id: "sns-dup")
      Webhook.process(message, source: @source)

      assert_no_difference [ "Webhook.count", "Event.count" ] do
        Webhook.process(message, source: @source)
      end
    end
  end
end
