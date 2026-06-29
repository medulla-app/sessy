module Sessy
module Event::Types
  extend ActiveSupport::Concern

  TYPES = {
    send: "Send",
    delivery: "Delivery",
    bounce: "Bounce",
    complaint: "Complaint",
    reject: "Reject",
    delivery_delay: "DeliveryDelay",
    rendering_failure: "RenderingFailure",
    subscription: "Subscription",
    open: "Open",
    click: "Click"
  }.freeze

  included do
    enum :event_type, TYPES, prefix: true

    validates :event_type, presence: true
  end

  def permanent_bounce?
    event_type_bounce? && bounce_type == "Permanent"
  end
end
end
