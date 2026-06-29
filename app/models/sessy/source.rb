module Sessy
class Source < ApplicationRecord
  include Colors
  include RetentionPolicy

  has_many :messages, dependent: :destroy
  has_many :events

  validates :name, presence: true
  validates :token, uniqueness: true

  before_validation :generate_token, on: :create

  scope :alphabetically, -> { order(name: :asc) }

  # Resolve the source for an incoming webhook token, creating it on the fly only
  # when the token matches the configured `Sessy.auto_source_token`. Returns nil
  # for any other unknown token (the controller 404s).
  def self.for_webhook(token)
    find_by(token: token) || provision(token)
  end

  def self.provision(token)
    return nil unless token.present? && token == Sessy.auto_source_token

    create!(token: token, name: Sessy.auto_source_name, retention_days: Sessy.auto_source_retention_days)
  rescue ActiveRecord::RecordNotUnique
    find_by(token: token)
  end

  private

  def generate_token
    self.token ||= SecureRandom.uuid
  end
end
end
