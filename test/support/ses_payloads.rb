module SesPayloads
  # A minimal SES event body (the JSON that rides inside an SNS "Message").
  def ses_delivery_event(message_id: "msg-1", recipients: [ "a@example.com" ], subject: "Hello")
    {
      "eventType" => "Delivery",
      "mail" => {
        "messageId" => message_id,
        "source" => "from@example.com",
        "timestamp" => "2026-01-01T00:00:00.000Z",
        "destination" => recipients,
        "commonHeaders" => { "subject" => subject },
        "tags" => { "ses:configuration-set" => [ "medulla-test-ses" ] }
      },
      "delivery" => {
        "timestamp" => "2026-01-01T00:00:05.000Z",
        "recipients" => recipients
      }
    }
  end

  def ses_bounce_event(message_id: "msg-bounce", recipients: [ "bounce@example.com" ], bounce_type: "Permanent")
    {
      "eventType" => "Bounce",
      "mail" => {
        "messageId" => message_id,
        "source" => "from@example.com",
        "timestamp" => "2026-01-01T00:00:00.000Z",
        "destination" => recipients,
        "commonHeaders" => { "subject" => "Oops" }
      },
      "bounce" => {
        "timestamp" => "2026-01-01T00:00:05.000Z",
        "bounceType" => bounce_type,
        "bouncedRecipients" => recipients.map { |e| { "emailAddress" => e } }
      }
    }
  end

  # The SNS envelope delivered to the webhook endpoint.
  def sns_notification(event, message_id: "sns-1")
    {
      "Type" => "Notification",
      "MessageId" => message_id,
      "Timestamp" => "2026-01-01T00:00:06.000Z",
      "Message" => event.to_json
    }
  end
end
