require "test_helper"

module Sessy
  class DashboardPagesTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers
    include SesPayloads

    setup do
      @source = Source.create!(name: "App")
      Event.ingest(EventPayload.new(ses_delivery_event(message_id: "msg-1")), source: @source)
      Event.ingest(EventPayload.new(ses_bounce_event(message_id: "msg-2")), source: @source)
      Event.ingest(EventPayload.new(ses_engagement_event("Open", message_id: "msg-1")), source: @source)
      Event.ingest(EventPayload.new(ses_engagement_event("Click", message_id: "msg-1")), source: @source)
    end

    test "every dashboard page renders" do
      {
        "sources" => sources_path,
        "source" => source_path(@source),
        "new source" => new_source_path,
        "edit source" => edit_source_path(@source),
        "setup" => source_setup_path(@source),
        "activity" => source_events_path(@source),
        "filtered activity" => source_events_path(@source, date_range: "all_time", event_types: [ "bounce" ], query: "bounce@example.com"),
        "activity csv" => source_events_path(@source, format: :csv, date_range: "all_time"),
        "delivered message" => source_message_path(@source, "msg-1"),
        "bounced message" => source_message_path(@source, "msg-2")
      }.each do |page, path|
        get path
        assert_response :success, "#{page} (#{path}) failed"
      end
    end

    test "activity search matches recipient and subject" do
      get source_events_path(@source, query: "OOPS", date_range: "all_time")
      assert response.body.include?("bounce@example.com"), "subject search missed the bounce"
      assert_not response.body.include?(">a@example.com<"), "subject search matched an unrelated recipient"

      get source_events_path(@source, query: "a@example", date_range: "all_time")
      assert response.body.include?("a@example.com"), "recipient search missed the delivery"
    end

    test "the setup page shows the webhook endpoint for the source" do
      get source_setup_path(@source)

      assert response.body.include?("http://www.example.com/sessy/webhooks/#{@source.token}"), "webhook endpoint missing"
    end

    test "a message page shows its events" do
      get source_message_path(@source, "msg-1")

      assert response.body.include?("msg-1"), "message id missing"
      assert response.body.include?("a@example.com"), "event recipient missing"
    end
  end
end
