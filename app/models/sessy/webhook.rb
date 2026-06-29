module Sessy
class Webhook < ApplicationRecord
  validates :sns_message_id, presence: true
  validates :sns_type, presence: true
  validates :sns_timestamp, presence: true
  validates :raw_payload, presence: true

  scope :reverse_chronologically, -> { order(created_at: :desc) }

  def mark_as_processed!
    update_column(:processed_at, Time.current)
  end

  def self.process(sns_message, source:)
    webhook = create_or_find_by!(sns_message_id: sns_message["MessageId"]) do |record|
      record.sns_type = sns_message["Type"]
      record.sns_timestamp = Time.parse(sns_message["Timestamp"])
      record.raw_payload = sns_message
    end

    return if webhook.processed_at?

    payload_hash = JSON.parse(sns_message["Message"])
    event_payload = EventPayload.new(payload_hash)
    Event.ingest(event_payload, source: source, webhook: webhook)
    webhook.mark_as_processed!
  end
end
end
