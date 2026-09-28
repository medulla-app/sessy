module Sessy
module SourcesHelper
  def config_set_name(source)
    "#{source.name.parameterize}-ses"
  end

  def sns_topic_name(source)
    "#{source.name.parameterize}-ses-events"
  end

  def source_webhook_url(source)
    "#{request.base_url}#{Sessy.webhook_path}/#{source.token}"
  end

  def bounce_label(bounce_type)
    case bounce_type
    when "Permanent"
      "Hard bounce"
    when "Transient"
      "Soft bounce"
    when "Undetermined"
      "Undetermined"
    else
      bounce_type
    end
  end
end
end
