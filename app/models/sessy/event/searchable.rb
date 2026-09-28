module Sessy
module Event::Searchable
  extend ActiveSupport::Concern

  included do
    scope :search, ->(term) {
      pattern = "%#{sanitize_sql_like(term.to_s.downcase)}%"
      left_joins(:message).where(
        "LOWER(#{table_name}.recipient_email) LIKE ? OR LOWER(#{Message.table_name}.subject) LIKE ?",
        pattern,
        pattern
      )
    }
  end
end
end
