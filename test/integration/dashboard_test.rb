require "test_helper"

module Sessy
  class DashboardTest < ActionDispatch::IntegrationTest
    include SesPayloads

    test "index renders" do
      Source.create!(name: "App")
      get "/admin/sessy/"
      assert_response :success
    end

    test "source overview renders" do
      source = Source.create!(name: "App")
      Webhook.process(sns_notification(ses_delivery_event), source: source)
      get "/admin/sessy/sources/#{source.id}"
      assert_response :success
    end

    test "events index renders" do
      source = Source.create!(name: "App")
      Webhook.process(sns_notification(ses_delivery_event), source: source)
      get "/admin/sessy/sources/#{source.id}/events"
      assert_response :success
    end
  end
end
