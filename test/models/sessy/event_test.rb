require "test_helper"

module Sessy
  class EventTest < ActiveSupport::TestCase
    include SesPayloads

    setup { @source = Source.create!(name: "App") }

    test "ingest creates one message and one event per recipient" do
      payload = EventPayload.new(ses_delivery_event(recipients: %w[a@example.com b@example.com]))

      assert_difference -> { Message.count } => 1, -> { Event.count } => 2 do
        Event.ingest(payload, source: @source)
      end

      assert_equal %w[a@example.com b@example.com], Event.order(:recipient_email).pluck(:recipient_email)
      assert_equal @source, Message.last.source
    end

    test "ingest is idempotent on the dedup key" do
      payload = EventPayload.new(ses_delivery_event)
      Event.ingest(payload, source: @source)

      assert_no_difference [ "Event.count", "Message.count" ] do
        Event.ingest(payload, source: @source)
      end
    end

    test "ingest records bounce_type for bounces" do
      payload = EventPayload.new(ses_bounce_event(bounce_type: "Permanent"))
      Event.ingest(payload, source: @source)

      event = Event.last
      assert event.event_type_bounce?
      assert event.permanent_bounce?
    end
  end
end
